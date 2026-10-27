# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.10.0-base

# build-time tokens for gated downloads are read from BuildKit secret
# mounts — they are never written to a layer or to image history.
# pass via: docker buildx build --secret id=hf_token,env=HF_TOKEN .

# install custom nodes into comfyui
RUN git clone https://github.com/comfyanonymous/ComfyUI /comfyui/custom_nodes/ComfyUI

# download models into comfyui
RUN --mount=type=secret,id=hf_token BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN="$(cat /run/secrets/hf_token 2>/dev/null || true)" comfy model download --url 'https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/diffusion_models/qwen_image_2.1_int8_convrot.safetensors' --relative-path models/diffusion_models --filename 'qwen_image_2.1_int8_convrot.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN --mount=type=secret,id=hf_token BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN="$(cat /run/secrets/hf_token 2>/dev/null || true)" comfy model download --url 'https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/vae/qwen_image_2.1_vae_bf16.safetensors' --relative-path models/vae --filename 'qwen_image_2.1_vae_bf16.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN --mount=type=secret,id=hf_token BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN="$(cat /run/secrets/hf_token 2>/dev/null || true)" comfy model download --url 'https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/text_encoders/qwen3vl_8b_int8_convrot.safetensors' --relative-path models/text_encoders --filename 'qwen3vl_8b_int8_convrot.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/

# user-provided inputs override the auto-generated placeholders above.
RUN wget --progress=dot:giga -O '/comfyui/input/example.png' "https://cool-anteater-319.convex.cloud/api/storage/8603b370-33c7-4f9d-91de-1cd6cc9c1887"
