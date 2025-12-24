function run(cmd) {
    fetch("http://localhost:8000/" + cmd)
        .then(res => res.json())
        .then(data => {
            document.getElementById("result").innerText =
                JSON.stringify(data, null, 2);
        })
        .catch(err => {
            document.getElementById("result").innerText =
                "エラー: " + err;
        });
}

