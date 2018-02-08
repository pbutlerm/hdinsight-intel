#az login 

# Set the right subscription 
az account set --subscription c1bebd58-3ae3-413d-913e-9f2f2bc638d9 

az group create --name sparkclusterpabutler2rg --location "Central US"

az group deployment create --name sparkclusterpabutler2 --resource-group sparkclusterpabutler2rg  --template-file azuredeploy.json



# Accept the HortonWorks new Public Key
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B9733A7A07513CADaz