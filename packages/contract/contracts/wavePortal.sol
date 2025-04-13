// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "hardhat/console.sol";

contract WavePortal {

    uint256 private _totalWaves;

    // NewWaveイベントの作成
    event NewWave(address indexed from, uint256 timestamp, string message);

    // Waveという構造体を作成(カスタマイズ可能)
    struct Wave {
        address waver; //「wave」を送ったユーザーのアドレス
        string message; // ユーザーが送ったメッセージ
        uint256 timestamp; // ユーザーが「wave」を送った時刻

    }

    // 構造体の配列を格納するための変数wavesを宣言(これで、ユーザーが送ってきたすべての「wave」を保持することができる)
    Wave[] private _waves;

    // constructor()は、コントラクトがデプロイされた瞬間に一度だけ呼ばれる関数
    // payableを加えることで、コントラクトに送金機能を実装
    constructor() payable {
    console.log("We have been constructed!");
}

    // _message(ユーザーがフロント側から送信するメッセージ)を要求するようにwave関数を更新。
    function wave(string memory _message) public {
        _totalWaves += 1;
        console.log("%s waved w/ message %s", msg.sender, _message);

        // 「wave」とメッセージを配列に格納。
        _waves.push(Wave(msg.sender, _message, block.timestamp));

        // コントラクト側でemitされたイベントに関する通知をフロントエンドで取得できるようにする。
        emit NewWave(msg.sender, block.timestamp, _message);

        /*
        * 「wave」を送ってくれたユーザーに0.0001ETHを送る
        */
        uint256 prizeAmount = 0.0001 ether;
        // ユーザーに送る ETH の額がコントラクトが持つ残高より下回っていることを確認
        require(
            prizeAmount <= address(this).balance,
            "Trying to withdraw more money than the contract has."
        );

        // ユーザーに送金を行うために実装
        (bool success, ) = (msg.sender).call{value: prizeAmount}("");
        // 送金が成功したかどうかを確認
        require(success, "Failed to withdraw money from contract.");
    }

     // 構造体配列のwavesを返してくれるgetAllWavesという関数を追加。これで、私たちのWEBアプリからwavesを取得することができる。
    function getAllWaves() public view returns (Wave[] memory) {
        return _waves;
    }

    function getTotalWaves() public view returns (uint256) {
        // コントラクトが出力する値をコンソールログで表示する。
        console.log("We have %d total waves!", _totalWaves);
        return _totalWaves;
    }
}