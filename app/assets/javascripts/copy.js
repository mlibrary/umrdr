function copyClick() {
  var copyText = document.getElementById("copy-input");
  copyText.select();
  document.execCommand("Copy");
}