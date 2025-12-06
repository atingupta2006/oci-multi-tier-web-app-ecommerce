# Mandatory Pre-Completion Verification Checklist

**⚠️ CRITICAL: Run this checklist BEFORE marking any topic as complete**

## Quick Verification Commands

Run these searches on the topic folder before finalizing:

```bash
# Check for fictional services
grep -ri "checkout\.example\|billing\.example\|example\.com" training-material/Day-X/Topic-Name/

# Check for other example apps
grep -ri "Class Enrollment\|Enrollment Web App" training-material/Day-X/Topic-Name/

# Check for Docker/Kubernetes
grep -ri "Docker\|Kubernetes\|docker\|kubernetes" training-material/Day-X/Topic-Name/

# Check for documentation references
grep -ri "docs/.*\.md\|Documentation\|Source:" training-material/Day-X/Topic-Name/
```

## Mandatory Checklist

### ✅ App References
- [ ] **NO** fictional services (checkout.example.com, etc.)
- [ ] **NO** other example apps (Class Enrollment, etc.)
- [ ] **ONLY** BharatMart used throughout
- [ ] All examples use BharatMart platform

### ✅ File References
- [ ] **NO** specific script paths (deployment/scripts/...)
- [ ] **NO** specific config paths (config/samples/...)
- [ ] **NO** specific code file paths (server/...)
- [ ] Only API endpoints (`/metrics`, `/api/health`)
- [ ] Only environment variables (as concepts)

### ✅ Technology Focus
- [ ] **NO** Docker/Kubernetes (unless very much needed)
- [ ] Focus on single-VM and OCI PaaS only
- [ ] OCI services mentioned appropriately

### ✅ Format
- [ ] Title format: `Topic X: Topic Name`
- [ ] Simple, demonstrable hands-on
- [ ] Conceptual, not file-specific
- [ ] No documentation references

### ✅ Complexity
- [ ] Complex concepts simplified or removed
- [ ] Only relevant content kept
- [ ] Simple enough to demonstrate in training

---

**If ANY checkbox is unchecked, DO NOT mark as complete. Fix issues first.**

