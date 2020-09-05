#!/bin/sh

METHOD="$1"
IMAGE_NAME="$2"
CI_COMMIT_REF_NAME="$3"
IMAGE_TAG="$4"

if [ "$METHOD" == "remove-tag" ]
then
  echo "Attempting to remove tag short sha tag from $CI_COMMIT_REF_NAME-rollback"
  DESC=$(aws ecr describe-images --repository-name $IMAGE_NAME --image-ids imageTag=$CI_COMMIT_REF_NAME-rollback ||:)

  if [ -z "$DESC" ]
  then
    echo "No image found for $IMAGE_NAME with tag $CI_COMMIT_REF_NAME-rollback"
    exit 0
  else
    TAG=$(aws ecr describe-images --repository-name $IMAGE_NAME --image-ids imageTag=$CI_COMMIT_REF_NAME-rollback | jq -r --arg IGTAG "$CI_COMMIT_REF_NAME-rollback" '.imageDetails[0].imageTags[] | select(.|contains($IGTAG) | not) | . ' | tr -d \")
    if [ -z "$TAG" ]
    then
      echo "No alternate tag found on $CI_COMMIT_REF_NAME-rollback image."
      exit 0
    else
      aws ecr batch-delete-image --repository-name $IMAGE_NAME --image-ids imageTag=$TAG
      echo "Image tag $TAG removed from rollback image"
      exit 0
    fi
  fi
fi

if [ "$METHOD" == "tag-current" ]
then
  echo "Attempting to add $CI_COMMIT_REF_NAME-current tag $IMAGE_NAME:$IMAGE_TAG"
  MANIFEST=$(aws ecr batch-get-image --repository-name $IMAGE_NAME --image-ids imageTag=$IMAGE_TAG --query 'images[].imageManifest' --output text ||:)

  if [ -z "$MANIFEST" ]
  then
    echo "No image found for $IMAGE_NAME with tag $IMAGE_TAG"
    exit 0
  else
    aws ecr put-image --repository-name $IMAGE_NAME --image-tag $CI_COMMIT_REF_NAME-current --image-manifest "$MANIFEST"
    echo "$IMAGE_NAME:$IMAGE_TAG tagged as $CI_COMMIT_REF_NAME-current"
    exit 0
  fi
fi

if [ "$METHOD" == "retag-rollback" ]
then
  echo "Attempting to retag $IMAGE_NAME:$CI_COMMIT_REF_NAME-current tag $IMAGE_NAME:$CI_COMMIT_REF_NAME-rollback"
  MANIFEST=$(aws ecr batch-get-image --repository-name $IMAGE_NAME --image-ids imageTag=$CI_COMMIT_REF_NAME-current --query 'images[].imageManifest' --output text ||:)

  if [ -z "$MANIFEST" ]
  then
    echo "No image found for $IMAGE_NAME with tag $CI_COMMIT_REF_NAME-current"
    exit 0
  else
    aws ecr put-image --repository-name $IMAGE_NAME --image-tag $CI_COMMIT_REF_NAME-rollback --image-manifest "$MANIFEST"
    echo "$IMAGE_NAME:$CI_COMMIT_REF_NAME-current retagged as -rollback"
    exit 0
  fi
fi
