# Training Material Enhancement Rules

This document contains all rules, constraints, and instructions for enhancing training materials. Follow these consistently for all future document updates.

## 1. Documentation References

### Rule: Minimize Documentation References
- ❌ **Don't reference** existing documentation files (e.g., `docs/...`) unless **very much needed**
- ✅ **Only reference** documentation if it's simple enough and absolutely necessary
- ✅ **Prefer**: Explain concepts directly rather than pointing to external docs

### Rationale
- Documentation might change or be removed
- Reduces complexity and dependencies
- Keeps content self-contained

---

## 2. App File and Script References

### Rule: Minimize App-Specific File References
- ❌ **Don't reference** specific deployment scripts (e.g., `deployment/scripts/deploy-*.sh`)
- ❌ **Don't reference** specific config file paths (e.g., `config/samples/*.env`)
- ❌ **Don't reference** specific code file paths unless absolutely essential
- ✅ **Keep only essential references**:
  - API endpoints (part of the application): `/metrics`, `/api/health`
  - Environment variables (concepts): `DEPLOYMENT_MODE`, `DATABASE_TYPE`, etc.
  - Conceptual descriptions (not file paths)

### Rationale
- Scripts and files might be renamed or removed
- Keeps content future-proof and less fragile
- Focuses on concepts rather than implementation details

---

## 3. Deployment Technology Focus

### Rule: OCI-First, Avoid Docker/Kubernetes
- ❌ **Don't mention** Docker or Kubernetes unless **very much needed**
- ✅ **Focus on**:
  - Single-VM deployments
  - OCI Compute instances
  - OCI PaaS services (OCI Autonomous Database, OCI Cache, etc.)
- ✅ **Use**: OCI deployment examples, single-VM configurations

### Rationale
- Training focuses on OCI cloud platform
- Students deploy to single-VM or OCI PaaS, not containers/orchestration

---

## 4. Topic Naming Convention

### Rule: Always Include Topic Number and Name
- ✅ **Format**: `## Topic X: Topic Name`
- ❌ **Don't use**: `## Subtopic: Topic Name` or just `## Topic Name`

### Example
```
✅ Topic 1: Introduction to SRE
✅ Topic 2: SRE vs DevOps vs Platform Engineering
```

---

## 5. Complexity Management

### Rule: Simplify or Remove Complex/Off-Topic Concepts
- ✅ **Keep**: Concepts directly relevant to the topic
- ❌ **Remove or simplify**: 
  - Complex concepts not directly relevant to the topic
  - Advanced topics that don't fit the current level
  - Off-topic technical details

### Process
- If unsure about complexity, **ask the user** before including
- Prefer simpler, more focused explanations

---

## 6. Hands-On Exercises

### Rule: Keep Simple and Demonstrable
- ✅ **Simple**: Viewing, basic commands, conceptual exercises
- ✅ **Demonstrable**: Can be easily shown in training
- ❌ **Avoid**: Complex setup, multi-step configurations, advanced scenarios
- ⚠️ **If complex**: Ask user before including

### Examples of Good Hands-On
- Viewing metrics endpoint: `curl http://localhost:3000/metrics`
- Viewing logs: `tail logs/api.log`
- Checking health: `curl http://localhost:3000/api/health`
- OCI Console navigation

---

## 7. Content Structure

### Rule: Conceptual Over Implementation-Specific
- ✅ **Focus on**: Concepts, principles, general approaches
- ✅ **Use**: Generic descriptions, conceptual examples
- ❌ **Avoid**: Specific file paths, script names, detailed implementation

### Examples
```
✅ "Configuration templates for different deployment scenarios"
❌ "config/samples/single-vm-production.env"

✅ "Automated deployment processes"
❌ "deployment/scripts/deploy-backend-oci.sh"
```

---

## 8. BharatMart Platform Integration

### Rule: Use ONLY BharatMart Platform
- ✅ **CRITICAL**: Use **ONLY** BharatMart platform in all examples and hands-on exercises
- ❌ **NEVER use**: Fictional services (checkout.example.com, billing services, etc.)
- ❌ **NEVER use**: Other example apps (Class Enrollment, etc.)
- ✅ **Always**: Reference BharatMart e-commerce platform
- ✅ **Keep**: References to API endpoints (`/metrics`, `/api/health`)
- ✅ **Keep**: Environment variables as configuration concepts
- ❌ **Don't**: Reference specific implementation files or scripts
- ❌ **Don't**: Make content dependent on specific code structure

### Examples
```
✅ "BharatMart exposes metrics at /metrics endpoint"
✅ "BharatMart e-commerce platform processes orders"
✅ "Configure via DEPLOYMENT_MODE environment variable"
❌ "checkout.example.com processes purchases" (WRONG - use BharatMart)
❌ "Class Enrollment Web App" (WRONG - use BharatMart)
❌ "See server/config/deployment.ts for adapter pattern"
❌ "Use deployment/scripts/deploy-backend-oci.sh"
```

### Pre-Enhancement Check
Before completing any enhancement, search for and remove:
- Any fictional service names
- Any other example apps
- Generic placeholder names that aren't BharatMart

---

## 9. Output Efficiency

### Rule: Minimize Token Usage
- ✅ **Keep**: Output minimal and concise
- ✅ **Focus**: On essential information only
- ✅ **Use**: Clear, direct summaries

---

## 10. Consistency Checks

### ⚠️ MANDATORY Pre-Completion Verification

**Before finalizing ANY document update, you MUST verify ALL of the following:**

#### App and Service References (CRITICAL)
- [ ] **NO fictional services** (checkout.example.com, billing.example.com, etc.)
- [ ] **NO other example apps** (Class Enrollment, etc.)
- [ ] **ONLY BharatMart** used throughout
- [ ] All hands-on exercises use BharatMart only

#### Documentation and File References
- [ ] No documentation file references (`docs/...`) unless absolutely necessary
- [ ] No specific script file references
- [ ] No specific config file paths (unless essential concepts)
- [ ] No specific code file paths (unless absolutely essential)

#### Technology Focus
- [ ] No Docker/Kubernetes references (unless very much needed)
- [ ] Focus on single-VM and OCI PaaS deployments only
- [ ] OCI services mentioned appropriately (Autonomous DB, Cache, etc.)

#### Format and Structure
- [ ] Topic title includes number and name: `Topic X: Name`
- [ ] Complex concepts simplified or removed
- [ ] Hands-on exercises are simple and demonstrable
- [ ] Content is conceptual, not file-specific
- [ ] Only essential references kept (API endpoints, env vars)

### Verification Commands
Before completing, run these checks:
1. Search for fictional service names
2. Search for other example apps
3. Search for Docker/Kubernetes mentions
4. Search for documentation references

---

## Summary Checklist

✅ **Minimize References**
- Documentation files
- App-specific scripts
- Config file paths
- Code file paths

✅ **Focus Areas**
- Single-VM deployments
- OCI PaaS services
- Conceptual explanations
- Simple hands-on exercises

✅ **Keep Essential Only**
- API endpoints (`/metrics`, `/api/health`)
- Environment variable names (as concepts)
- OCI service names (Autonomous DB, Cache, etc.)

✅ **Format**
- Topic number + name in titles
- Conceptual over implementation-specific
- Simple and demonstrable exercises

---

**Last Updated**: Based on user feedback during Topic 1 and Topic 2 enhancements

