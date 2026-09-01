// Venus 网关（chat/completions）对 gpt-5.x 系拒收 max_tokens、只收
// max_completion_tokens。@ai-sdk/openai-compatible 把 maxOutputTokens 序列化成
// max_tokens 且无配置开关，故在 chat.params 里改写（同 opencode 内置
// Cerebras/Snowflake 补丁机制）。仅作用于 venus provider。

export const VenusMaxCompletionTokens = async () => {
  return {
    "chat.params": async (input, output) => {
      if (input.model.providerID !== "venus") return;
      if (input.model.api.npm !== "@ai-sdk/openai-compatible") return;
      const { maxOutputTokens } = output;
      if (maxOutputTokens === undefined) return;
      output.options = {
        ...output.options,
        max_completion_tokens: maxOutputTokens,
      };
      output.maxOutputTokens = undefined;
    },
  };
};