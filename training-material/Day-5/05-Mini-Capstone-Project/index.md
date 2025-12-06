# Day 5 – SRE Culture, Security, and Operational Excellence

## Topic 5: Mini Capstone Project



### Audience Context: IT Engineers and Developers

---

## 0. Deployment Assumptions

For this capstone project, you will work with **BharatMart e-commerce platform** to demonstrate SRE skills learned throughout the training.

#### Project Scope
* **BharatMart platform** will be deployed using OCI Resource Manager
* **SLIs and SLOs** will be defined based on business requirements
* **Alarms and dashboards** will be configured for monitoring
* **Incident simulation** will be performed and resolved
* **Postmortem** will be conducted for learning

#### Available Components
* OCI Resource Manager for infrastructure deployment
* OCI Monitoring for alarms and dashboards
* BharatMart application for hands-on exercises
* All concepts learned from Days 1-5

This capstone project integrates all SRE concepts learned throughout the 5-day training program.

---

## 1. Concept Overview

**Mini Capstone Project** is a comprehensive hands-on exercise that brings together all SRE concepts and practices covered in the training:

* Infrastructure automation with Resource Manager
* SLI/SLO definition and tracking
* Monitoring and alerting configuration
* Incident response and postmortem
* Integration of all SRE practices

#### Project Objectives

* **Demonstrate Understanding:** Apply all learned SRE concepts
* **Practice Skills:** Hands-on experience with real tools
* **Integrate Practices:** Combine multiple SRE disciplines
* **Build Confidence:** Complete end-to-end SRE workflow

---

## 2. How This Applies to IT Engineers and Developers

### IT Engineers

* Deploy infrastructure using automation (Resource Manager)
* Configure monitoring and alerting (OCI Monitoring)
* Set up dashboards for visibility
* Practice incident response procedures
* Integrate infrastructure with observability

### Developers

* Define SLIs/SLOs for application features
* Understand observability requirements
* Participate in incident response
* Learn from postmortems
* Collaborate with SRE on reliability

### Unified View

```
Infrastructure → Application → Observability → Monitoring → Incident Response → Improvement
```

---

## 3. Project Components

## 3.1 Deploy App via Resource Manager

### Objective

Deploy BharatMart infrastructure using OCI Resource Manager to demonstrate Infrastructure as Code (IaC) practices.

### Tasks

1. **Create Terraform Configuration:**
   * Define VCN and networking
   * Configure Compute instances
   * Set up Load Balancer
   * Define security rules

2. **Deploy via Resource Manager:**
   * Upload Terraform configuration
   * Create Resource Manager stack
   * Run plan to validate
   * Apply configuration to create infrastructure

3. **Deploy Application:**
   * Install BharatMart on Compute instances
   * Configure application environment
   * Verify deployment success

### Deliverables

* Terraform configuration files
* Resource Manager stack deployed
* BharatMart application running
* Infrastructure documented

---

## 3.2 Define SLIs and SLOs

### Objective

Define Service Level Indicators (SLIs) and Service Level Objectives (SLOs) for BharatMart platform based on business requirements.

### Tasks

1. **Identify Key User Journeys:**
   * Browse products
   * Add to cart
   * Checkout and payment
   * Order confirmation

2. **Define SLIs:**
   * Availability: Uptime percentage
   * Latency: P95 request duration
   * Error Rate: Percentage of failed requests
   * Throughput: Requests per second

3. **Set SLOs:**
   * Availability: 99.9% (43 minutes downtime/month)
   * Latency: P95 < 500ms for 99% of requests
   * Error Rate: < 0.1% of requests
   * Throughput: Support 1000 requests/second

4. **Calculate Error Budget:**
   * Error budget = 100% - SLO
   * Example: 99.9% availability → 0.1% error budget

### Deliverables

* SLI definitions documented
* SLO targets specified
* Error budget calculated
* Measurement method defined

---

## 3.3 Configure Alarms and Dashboard

### Objective

Configure monitoring alarms and dashboards to track SLI compliance and detect incidents.

### Tasks

1. **Configure Alarms:**
   * Availability alarm (service down)
   * Latency alarm (P95 > 500ms)
   * Error rate alarm (> 0.1%)
   * Health check alarm

2. **Create Dashboard:**
   * Availability metrics
   * Latency percentiles (P50, P95, P99)
   * Error rate trends
   * Request throughput
   * SLO compliance visualization

3. **Set Up Notifications:**
   * Configure notification channels
   * Route alarms to appropriate channels
   * Test alarm functionality

### Deliverables

* Alarms configured in OCI Monitoring
* Dashboard created with key metrics
* Notifications working correctly
* Alarm testing documented

---

## 3.4 Perform Incident Simulation and Postmortem

### Objective

Simulate an incident, respond to it, and conduct a blameless postmortem to practice incident response procedures.

### Tasks

1. **Simulate Incident:**
   * Enable chaos engineering (latency injection)
   * Trigger alarm
   * Observe system behavior

2. **Respond to Incident:**
   * Detect incident (alarm received)
   * Acknowledge and assess severity
   * Investigate root cause
   * Mitigate impact
   * Resolve permanently
   * Verify resolution

3. **Conduct Postmortem:**
   * Document incident timeline
   * Identify root cause
   * Assess impact
   * Identify what went well
   * Identify improvements needed
   * Create action items

### Deliverables

* Incident timeline documented
* Postmortem document created
* Action items defined
* Lessons learned captured

---

## 4. Project Structure

### Phase 1: Infrastructure Deployment (2 hours)

##### Activities
* Create Terraform configuration
* Deploy via Resource Manager
* Deploy BharatMart application
* Verify deployment

##### Outcomes
* Infrastructure deployed
* Application running
* Basic connectivity verified

---

### Phase 2: Observability Setup (2 hours)

##### Activities
* Define SLIs and SLOs
* Configure alarms
* Create dashboard
* Test monitoring

##### Outcomes
* SLIs/SLOs documented
* Alarms configured
* Dashboard created
* Monitoring validated

---

### Phase 3: Incident Response (1.5 hours)

##### Activities
* Simulate incident
* Respond and resolve
* Document timeline
* Conduct postmortem

##### Outcomes
* Incident resolved
* Timeline documented
* Postmortem completed
* Action items created

---

## 5. Project Deliverables

### 1. Infrastructure Documentation

* Terraform configuration files
* Resource Manager stack details
* Deployment procedure documented
* Infrastructure diagram

### 2. SLI/SLO Documentation

* SLI definitions
* SLO targets
* Error budget calculations
* Measurement methodology

### 3. Monitoring Configuration

* Alarm configurations
* Dashboard screenshots
* Notification setup
* Monitoring runbook

### 4. Incident Response Documentation

* Incident timeline
* Root cause analysis
* Postmortem document
* Action items and follow-up

---

## 6. Success Criteria

### Infrastructure

* ✅ Infrastructure deployed via Resource Manager
* ✅ BharatMart application running
* ✅ Health checks passing
* ✅ Connectivity verified

### Observability

* ✅ SLIs and SLOs defined
* ✅ Alarms configured and tested
* ✅ Dashboard created with key metrics
* ✅ Monitoring operational

### Incident Response

* ✅ Incident simulated successfully
* ✅ Incident detected and acknowledged
* ✅ Root cause identified
* ✅ Incident resolved
* ✅ Postmortem conducted

### Overall

* ✅ All components integrated
* ✅ Documentation complete
* ✅ Best practices followed
* ✅ Learning demonstrated

---

## 7. Project Timeline

**Total Duration: 5.5 hours**

* **Infrastructure Deployment:** 2 hours
* **Observability Setup:** 2 hours
* **Incident Response:** 1.5 hours

#### Optional Extension
* Additional incident scenarios
* Advanced dashboard customization
* Extended postmortem discussion

---

## 8. Tips for Success

### Planning

* Review all concepts before starting
* Plan each phase carefully
* Allocate time appropriately
* Keep notes throughout

### Execution

* Follow procedures step-by-step
* Test as you go
* Document everything
* Ask for help when stuck

### Documentation

* Document decisions and rationale
* Capture screenshots
* Write clear procedures
* Note any issues encountered

### Learning

* Reflect on each phase
* Connect concepts together
* Identify areas for improvement
* Share learnings with team

---

## 9. Common Challenges

### Infrastructure Deployment

* Terraform syntax errors
* Resource conflicts
* Permission issues
* Network configuration

##### Solutions
* Validate Terraform syntax
* Check for existing resources
* Verify IAM permissions
* Review network configuration

### Observability Setup

* Metric collection issues
* Alarm not triggering
* Dashboard not updating
* SLO calculation errors

##### Solutions
* Verify metric endpoints
* Check alarm thresholds
* Validate dashboard queries
* Review SLO calculations

### Incident Response

* Incident not detected
* Root cause unclear
* Resolution delayed
* Postmortem incomplete

##### Solutions
* Check alarm configuration
* Review metrics and logs
* Follow incident procedures
* Complete all postmortem sections

---

## 10. Assessment

### Evaluation Criteria

##### Infrastructure (25%)
* Deployment successful
* Configuration correct
* Documentation complete

##### Observability (25%)
* SLIs/SLOs well-defined
* Alarms functional
* Dashboard informative

##### Incident Response (25%)
* Incident handled correctly
* Postmortem thorough
* Action items defined

##### Integration (25%)
* All components work together
* Best practices followed
* Learning demonstrated

---

## 11. Next Steps

After completing this capstone project:

* **Apply Learnings:** Use skills in real projects
* **Continue Learning:** Explore advanced topics
* **Share Knowledge:** Teach others
* **Improve Practices:** Refine processes
* **Build Experience:** Practice regularly

---

## 12. Additional Notes

* This capstone integrates all 5 days of training
* Focus on demonstrating understanding, not perfection
* Learning from mistakes is valuable
* Collaboration enhances learning
* Document everything for reference

---
