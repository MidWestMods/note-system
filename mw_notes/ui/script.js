window.addEventListener('message', function (event) {
  if (event.data.type === "open") {
    document.body.style.display = "flex";
    document.getElementById("noteInput").placeholder = event.data.placeholder || "Write your note here...";
  } else if (event.data.type === "close") {
    document.body.style.display = "none";
    document.getElementById("noteInput").value = "";
  }
});

function submitNote() {
  const text = document.getElementById("noteInput").value;
  fetch(`https://${GetParentResourceName()}/submitNote`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ note: text }),
  }).then(() => {
    document.body.style.display = "none";
    document.getElementById("noteInput").value = "";
  });
}

function closeUI() {
  fetch(`https://${GetParentResourceName()}/closeUI`, {
    method: "POST"
  }).then(() => {
    document.body.style.display = "none";
    document.getElementById("noteInput").value = "";
  });
}