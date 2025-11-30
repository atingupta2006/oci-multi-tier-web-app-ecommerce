# Day 5: Production Readiness

Day 5 curriculum covering production deployment, scaling, release gates, and SRE best practices.

## Learning Objectives

By the end of Day 5, participants will:
- Understand production deployment
- Learn scaling strategies
- Practice release gates
- Understand reliability engineering
- Review SRE best practices

**Source:** Day 5 objectives based on production features.

## Morning Session: Production Deployment

### Lecture: Production Deployment (1 hour)

**Topics:**
- Production deployment modes
- Infrastructure requirements
- Security considerations
- Monitoring setup
- Backup strategies

**Source:** Deployment documentation in `docs/05-deployment/`.

### Lab 1: Kubernetes Deployment (1 hour)

**Objective:** Deploy to Kubernetes

**Steps:**
1. Review Kubernetes manifests
2. Create namespace
3. Create secrets
4. Create ConfigMap
5. Deploy Redis
6. Deploy backend
7. Deploy workers
8. Deploy ingress
9. Verify deployment

**Manifests:**
- `deployment/kubernetes/namespace.yaml`
- `deployment/kubernetes/configmap.yaml`
- `deployment/kubernetes/backend-deployment.yaml`
- `deployment/kubernetes/workers-deployment.yaml`
- `deployment/kubernetes/ingress.yaml`

**Source:** Kubernetes deployment in `docs/05-deployment/05-kubernetes-deployment.md`.

### Lab 2: Production Configuration (1 hour)

**Objective:** Configure for production

**Steps:**
1. Review environment variables
2. Configure secrets management
3. Set up monitoring
4. Configure logging
5. Enable health checks
6. Set resource limits
7. Configure auto-scaling

**Configuration:**
- Production environment variables
- Secrets in Kubernetes/OCI Vault
- Prometheus monitoring
- Structured logging
- Health check endpoints

**Source:** Production configuration in `docs/04-configuration/`.

## Afternoon Session: Scaling & Reliability

### Lecture: Scaling Strategies (1 hour)

**Topics:**
- Horizontal vs vertical scaling
- Auto-scaling configuration
- Load balancing
- Database scaling
- Cache scaling

**Source:** Scaling guide in `docs/05-deployment/08-scaling-guide.md`.

### Lab 3: Configure Auto-Scaling (1 hour)

**Objective:** Set up horizontal pod autoscaling

**Steps:**
1. Review HPA configuration
2. Configure CPU/Memory targets
3. Set min/max replicas
4. Test scaling behavior
5. Monitor scaling events
6. Adjust thresholds

**HPA Configuration:**
- Min replicas: 2
- Max replicas: 10
- CPU target: 70%
- Memory target: 80%

**Source:** HPA in `deployment/kubernetes/backend-deployment.yaml` lines 113-155.

### Lab 4: Release Gate Practice (1 hour)

**Objective:** Practice release gate process

**Steps:**
1. Make code changes
2. Run E2E tests (`npm run test:e2e`)
3. Run SRE validation (`npm run test:sre`)
4. Review test results
5. Fix any failures
6. Re-run validation
7. Document release readiness

**Release Gate:**
- All E2E tests must pass
- SRE validation must pass
- Health checks must pass
- Metrics must be available

**Source:** Release gates in `docs/08-testing/06-release-gates.md`.

### Lab 5: Reliability Testing (1 hour)

**Objective:** Test system reliability

**Steps:**
1. Run load tests
2. Monitor metrics
3. Check error rates
4. Verify SLO compliance
5. Test failure scenarios
6. Verify recovery

**Reliability Tests:**
- Load testing
- Stress testing
- Failure injection
- Recovery testing

**Source:** Reliability testing concepts.

## Advanced Session: SRE Best Practices

### Lecture: SRE Principles (1 hour)

**Topics:**
- Error budgets
- SLOs and SLIs
- Toil reduction
- Automation
- Monitoring and alerting

**Source:** SRE principles and best practices.

### Lab 6: SLO Definition (1 hour)

**Objective:** Define and monitor SLOs

**Steps:**
1. Identify key services
2. Define SLO targets
3. Calculate error budgets
4. Create Prometheus queries
5. Set up alerts
6. Monitor compliance

**SLO Examples:**
- Order success rate: 99.9%
- Payment success rate: 99.5%
- API availability: 99.9%
- API latency (P95): < 500ms

**Source:** SLOs in `docs/06-observability/08-slos-and-error-budgets.md`.

### Lab 7: Production Readiness Checklist (30 minutes)

**Objective:** Complete production readiness checklist

**Checklist:**
- [ ] Environment variables configured
- [ ] Secrets secured
- [ ] Monitoring configured
- [ ] Logging configured
- [ ] Health checks working
- [ ] Auto-scaling configured
- [ ] Backup strategy in place
- [ ] Security hardened
- [ ] Documentation complete
- [ ] Runbooks created

**Source:** Production readiness checklist.

## Hands-On Exercises

### Exercise 1: Production Deployment Plan

**Task:** Create production deployment plan:
- Infrastructure requirements
- Deployment steps
- Rollback plan
- Monitoring setup
- Security checklist

**Source:** Production deployment planning.

### Exercise 2: Scaling Plan

**Task:** Create scaling plan:
- Current capacity
- Expected load
- Scaling triggers
- Resource limits
- Cost estimation

**Source:** Scaling planning exercise.

### Exercise 3: Runbook Creation

**Task:** Create production runbooks:
- Deployment procedures
- Scaling procedures
- Incident response
- Maintenance procedures

**Source:** Runbook creation exercise.

## Key Concepts

### Production Deployment

**Requirements:**
- High availability
- Scalability
- Security
- Monitoring
- Backup and recovery

**Source:** Production deployment requirements.

### Release Gates

**Criteria:**
- All tests pass
- Health checks pass
- Metrics available
- Documentation updated

**Source:** Release gate criteria in `scripts/full-sre-e2e.js`.

### Reliability Engineering

**Principles:**
- Design for failure
- Monitor everything
- Automate operations
- Reduce toil
- Learn from incidents

**Source:** Reliability engineering principles.

## Assessment

### Quiz Questions

1. What are the production deployment requirements?
2. How does auto-scaling work?
3. What is a release gate?
4. What are SRE best practices?

**Source:** Assessment questions based on Day 5 content.

### Lab Completion

**Criteria:**
- Kubernetes deployment completed
- Production configuration done
- Auto-scaling configured
- Release gate practiced
- SLOs defined
- Production readiness checklist completed

**Source:** Lab completion criteria.

## Resources

### Documentation

- [Deployment Guides](../05-deployment/) - Complete deployment documentation
- [Scaling Guide](../05-deployment/08-scaling-guide.md) - Scaling strategies
- [Release Gates](../08-testing/06-release-gates.md) - Release gate process
- [SLOs & Error Budgets](../06-observability/08-slos-and-error-budgets.md) - SLO definition

### Code References

- `deployment/kubernetes/` - Kubernetes manifests
- `scripts/full-sre-e2e.js` - Release gate script
- `server/config/deployment.ts` - Deployment configuration

## Final Project

### Requirements

1. **Deploy Application:**
   - Deploy to Kubernetes or multi-tier
   - Configure all components
   - Verify health checks

2. **Configure Monitoring:**
   - Set up Prometheus
   - Create Grafana dashboards
   - Configure alerts

3. **Define SLOs:**
   - Define SLO targets
   - Set up monitoring
   - Create alerts

4. **Run Release Gate:**
   - Run E2E tests
   - Run SRE validation
   - Verify readiness

5. **Document:**
   - Deployment procedures
   - Runbooks
   - Incident response

**Source:** Final project requirements.

## Next Steps

- [Training Overview](01-training-overview.md) - Training overview
- [Incident Simulation Labs](07-incident-simulation-labs.md) - Incident labs
- [RCA Labs](08-rca-labs.md) - Root cause analysis labs

