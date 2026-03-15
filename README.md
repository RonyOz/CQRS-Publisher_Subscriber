# CQRS and Pub/Sub Demo

Demo simple con dos patrones:

1. CQRS: separa escritura y lectura en dos servicios.
2. Publisher-Subscriber: un publicador envía mensajes y dos suscriptores los reciben por Azure Service Bus.

## Requisitos

- Node.js 16+ y npm
- Para Pub/Sub: Azure Service Bus con:
  - Topic: demo-topic
  - Subscriptions: subscription-a, subscription-b
- Variable de entorno: SERVICE_BUS_CONNECTION_STRING

## Estructura

```txt
cqrs/
  command-service/   (write, puerto 3001)
  query-service/     (read, puerto 3002)

pubsub/
  publisher/
  subscriber-a/
  subscriber-b/
```

## Instalacion rapida

Desde la raiz del proyecto:

```bash
./setup.sh
```

O instala por servicio con npm install.

## Ejecutar CQRS

Terminal 1:

```bash
cd cqrs/command-service
npm run dev
```

Terminal 2:

```bash
cd cqrs/query-service
npm run dev
```

Probar:

```bash
curl -X POST http://localhost:3001/command \
  -H "Content-Type: application/json" \
  -d '{"id":"user-001","name":"John Doe"}'

curl http://localhost:3002/query
```

## Ejecutar Pub/Sub

Configura la conexion:

```bash
export SERVICE_BUS_CONNECTION_STRING="<tu-connection-string>"
```

Terminal 1:

```bash
cd pubsub/subscriber-a
npm run dev
```

Terminal 2:

```bash
cd pubsub/subscriber-b
npm run dev
```

Terminal 3:

```bash
cd pubsub/publisher
npm run dev
```

## Azure rapido (solo si no lo tienes creado)

```bash
az group create --name cloud-patterns --location eastus

az servicebus namespace create \
  --resource-group cloud-patterns \
  --name cloud-patterns-sb \
  --location eastus

az servicebus topic create \
  --resource-group cloud-patterns \
  --namespace-name cloud-patterns-sb \
  --name demo-topic

az servicebus topic subscription create \
  --resource-group cloud-patterns \
  --namespace-name cloud-patterns-sb \
  --topic-name demo-topic \
  --name subscription-a

az servicebus topic subscription create \
  --resource-group cloud-patterns \
  --namespace-name cloud-patterns-sb \
  --topic-name demo-topic \
  --name subscription-b
```

## Docker

```bash
cp .env.example .env
docker-compose up -d --build
docker-compose down
```

## Terraform

Infra base en Azure (RG + red + VM + Service Bus) en:

`infra/terraform`

Uso rapido:

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# editar terraform.tfvars con tu clave SSH publica

terraform init
terraform plan
terraform apply
```

Cuando termine, revisa los outputs para IP publica y datos de Service Bus.

## Notas

- CQRS guarda datos en memoria; al reiniciar se pierde el estado.
- El publisher de Pub/Sub termina cuando acaba de enviar mensajes.
