import Bull, { Queue, Job } from 'bull';
import { logger } from './logger';

const REDIS_URL = process.env.REDIS_URL || 'redis://localhost:6379';

export interface OrderProcessingJob {
  orderId: string;
  userId: string;
  totalAmount: number;
  items: Array<{
    productId: string;
    quantity: number;
    price: number;
  }>;
}

export interface EmailNotificationJob {
  to: string;
  subject: string;
  body: string;
  type: 'order_confirmation' | 'payment_success' | 'payment_failed';
  orderId: string;
}

export interface PaymentProcessingJob {
  orderId: string;
  amount: number;
  paymentMethod: string;
  userId: string;
}

export const orderQueue: Queue<OrderProcessingJob> = new Bull('order-processing', REDIS_URL, {
  defaultJobOptions: {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 2000,
    },
    removeOnComplete: 100,
    removeOnFail: 50,
  },
});

export const emailQueue: Queue<EmailNotificationJob> = new Bull('email-notifications', REDIS_URL, {
  defaultJobOptions: {
    attempts: 5,
    backoff: {
      type: 'exponential',
      delay: 1000,
    },
    removeOnComplete: 50,
    removeOnFail: 25,
  },
});

export const paymentQueue: Queue<PaymentProcessingJob> = new Bull('payment-processing', REDIS_URL, {
  defaultJobOptions: {
    attempts: 3,
    backoff: {
      type: 'fixed',
      delay: 5000,
    },
    removeOnComplete: 100,
    removeOnFail: 50,
  },
});

orderQueue.on('error', (error) => {
  logger.error('Order queue error:', error);
});

emailQueue.on('error', (error) => {
  logger.error('Email queue error:', error);
});

paymentQueue.on('error', (error) => {
  logger.error('Payment queue error:', error);
});

orderQueue.on('completed', (job: Job) => {
  logger.info(`Order processing job ${job.id} completed`);
});

emailQueue.on('completed', (job: Job) => {
  logger.info(`Email notification job ${job.id} completed`);
});

paymentQueue.on('completed', (job: Job) => {
  logger.info(`Payment processing job ${job.id} completed`);
});

orderQueue.on('failed', (job: Job, err: Error) => {
  logger.error(`Order processing job ${job.id} failed:`, err);
});

emailQueue.on('failed', (job: Job, err: Error) => {
  logger.error(`Email notification job ${job.id} failed:`, err);
});

paymentQueue.on('failed', (job: Job, err: Error) => {
  logger.error(`Payment processing job ${job.id} failed:`, err);
});

export const queueService = {
  async addOrderToQueue(data: OrderProcessingJob): Promise<Job<OrderProcessingJob>> {
    return orderQueue.add(data, {
      priority: 1,
    });
  },

  async addEmailToQueue(data: EmailNotificationJob): Promise<Job<EmailNotificationJob>> {
    return emailQueue.add(data, {
      priority: data.type === 'payment_failed' ? 2 : 3,
    });
  },

  async addPaymentToQueue(data: PaymentProcessingJob): Promise<Job<PaymentProcessingJob>> {
    return paymentQueue.add(data, {
      priority: 1,
    });
  },

  async getQueueStats() {
    const [orderStats, emailStats, paymentStats] = await Promise.all([
      orderQueue.getJobCounts(),
      emailQueue.getJobCounts(),
      paymentQueue.getJobCounts(),
    ]);

    return {
      orders: orderStats,
      emails: emailStats,
      payments: paymentStats,
    };
  },
};
