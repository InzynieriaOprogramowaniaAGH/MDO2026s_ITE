# Zajęcia 11

# Wdrażanie na zarządzalne kontenery: Kubernetes (2)

## Eksponowanie

Wdróż swój web-server za pomocą *deplymentu* w pliku YAML. Wdróż dużą liczbę podów (np. 36). Wyeksponuj dostęp do swojego web-serwera:

 * Do jednego poda
 * Do deploymentu
 * Do serwisu ((wyeksponuj)[https://kubernetes.io/docs/reference/kubectl/generated/kubectl_expose/] deployment)
    * Dedykowanym poleceniem
	* Dodatkowym plikiem YAML
 
Możesz użyć przekierowania portów VSCode.

Przeskaluj wdrożenie:

 * Za pomocą dyrektywy `scale`
 * Za pomocą zaaplikowania nowego pliku YAML (pokaż różnice między YAML-ami)
 
Sprawdź, do którego poda łączysz się po przeskalowaniu. Jeżeli logi nie są czytelne, użyj `nginx`.
