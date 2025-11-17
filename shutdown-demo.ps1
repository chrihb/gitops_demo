# -----------------------------
# Shutdown GitOps Demo Script
# -----------------------------

Write-Host "Stopping demo app..."
kubectl scale deployment demo --replicas=0

Write-Host "Scaling down Argo CD..."
kubectl scale deployment argocd-server -n argocd --replicas=0
kubectl scale deployment argocd-repo-server -n argocd --replicas=0
kubectl scale deployment argocd-application-controller -n argocd --replicas=0
kubectl scale deployment argocd-dex-server -n argocd --replicas=0

Write-Host "`nAll deployments scaled down. You can now safely close Docker Desktop if desired."
