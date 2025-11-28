import { Job } from 'bull';
import { emailQueue, EmailNotificationJob } from '../config/queue';
import { logger } from '../config/logger';

emailQueue.process(async (job: Job<EmailNotificationJob>) => {
  const { to, subject, body, type, orderId } = job.data;

  logger.info(`Sending ${type} email for order ${orderId} to ${to}`);

  try {
    await job.progress(20);

    await new Promise((resolve) => setTimeout(resolve, 1000));

    await job.progress(60);

    logger.info(`Email sent successfully: ${type} for order ${orderId}`);

    await job.progress(100);

    return {
      success: true,
      emailType: type,
      sentAt: new Date().toISOString(),
    };
  } catch (error) {
    logger.error(`Failed to send email for order ${orderId}:`, error);
    throw error;
  }
});

logger.info('Email worker started');
