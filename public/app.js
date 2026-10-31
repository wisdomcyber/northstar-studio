const form = document.querySelector("#contact-form");
const status = document.querySelector("#form-status");

form.addEventListener("submit", async (event) => {
  event.preventDefault();
  const submitButton = form.querySelector("button");
  submitButton.disabled = true;
  status.textContent = "Sending...";

  try {
    const response = await fetch("/api/contact", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(Object.fromEntries(new FormData(form)))
    });
    const result = await response.json();

    if (!response.ok) {
      throw new Error(result.error || "Could not send the message.");
    }

    form.reset();
    status.textContent = "Thanks. Your message has been sent.";
  } catch (error) {
    status.textContent = error.message;
  } finally {
    submitButton.disabled = false;
  }
});
