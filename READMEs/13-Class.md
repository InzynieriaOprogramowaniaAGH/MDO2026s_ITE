# Zajęcia 13

# Wdrażanie na zarządzalne kontenery w chmurze (Azure)
## Zadania do wykonania
### Przygotowanie kontenera
 - Proszę upewnić się, że dysponuje się własnym kontenerem z aplikacją (najlepiej tym z *pipeline'a*)
 - Proszę zaktualizować wersję kontenera obecną na Docker Hub
 
### Zapoznanie z platformą
 - Konto do odblokowania za pomocą studenckiego konta Microsoft:
   - [Personal](https://azure.microsoft.com/en-us/free/), całkowicie opcjonalnie
   - Przez [Panel AGH](https://panel.agh.edu.pl/)  (student - **zalecane**)
 - [Cennik](https://azure.microsoft.com/en-us/pricing/details/container-instances/ ) do przeczytania (ze zrozumieniem!!)
 - [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart) dla powłok Bash i PowerShell, narzędzie potrzebne do wdrożenia
 - **Miej na uwadze, że zalogowanie ACS do Azure'a i wołanie `az` na instancji zużywa kredyty!**
 - [Procedura wdrożenia kontenera](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-quickstart)
 - [Przygotowanie aplikacji](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-tutorial-prepare-app)
 - "Push image to Azure Container Registry" nie jest potrzebne!
 - *"Nie musisz tworzyć Docker Registry w Azure! Twoje obrazy już są na Docker Hubie!"*

### Zadanie do wykonania
 1. Utwórz własny [*Resource Group*](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
 2. Wdróż swój kontener z Docker Hub w swoim Azure
    * Sprawdź, czy potrzebujesz *container registry cache*?
    * Alternatywnie możesz wysłać swój obraz do Docker registry Azure'a?
 4. Wykaż, że kontener został uruchomiony i pracuje, pobierz logi, przedstaw metodę dostępu do serwowanej usługi HTTP
 5. Zatrzymaj i usuń kontener, pamiętaj o *resource group* (to bardzo ważne!)
