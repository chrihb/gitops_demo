# -----------------------------
# Startup GitOps Demo Script with Wait
# -----------------------------

function Wait-ForPodsReady {
    param(
        [string]$LabelSelector = "",
        [string]$Namespace = "default"
    )

    Write-Host "Waiting for pods in namespace '$Namespace' with selector '$LabelSelector' to be ready..."
    while ($true) {
        $pods = kubectl get pods -n $Namespace -l $LabelSelector -o json
        $allReady = $true

        foreach ($pod in ($pods | ConvertFrom-Json).items) {
            $statuses = $pod.status.containerStatuses
            foreach ($status in $statuses) {
                if (-not $status.ready) {
                    $allReady = $false
                }
            }
        }

        if ($allReady) { break }
        Start-Sleep -Seconds 2
    }
    Write-Host "All pods ready!"
}

# -----------------------------
# Scale Argo CD
# -----------------------------
Write-Host "Starting Argo CD..."
kubectl scale deployment argocd-server -n argocd --replicas=1
kubectl scale deployment argocd-repo-server -n argocd --replicas=1
kubectl scale deployment argocd-application-controller -n argocd --replicas=1
kubectl scale deployment argocd-dex-server -n argocd --replicas=1

# -----------------------------
# Scale Demo App
# -----------------------------
Write-Host "Starting demo app..."
kubectl scale deployment demo --replicas=1

# -----------------------------
# Wait for pods
# -----------------------------
Wait-ForPodsReady -Namespace "argocd"
Wait-ForPodsReady -Namespace "default" -LabelSelector "app=demo"

# -----------------------------
# Port-forward
# -----------------------------
Write-Host "`nStarting port-forwards..."
Start-Process powershell -ArgumentList "-NoExit kubectl port-forward svc/demo 8888:80"
Start-Process powershell -ArgumentList "-NoExit kubectl port-forward svc/argocd-server -n argocd 8080:443"

Write-Host "`nAll pods are running. Port-forwards started!"
Write-Host "Demo app: http://localhost:8888"
Write-Host "Argo CD UI: https://localhost:8080"
