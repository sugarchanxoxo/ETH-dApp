// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "hardhat/console.sol";

contract WavePortal {
    uint256 private _totalWaves;
    /* 乱数生成のための基盤となるシード（種）を作成 */
    uint256 private _seed;

    // NewWaveイベントの作成
    event NewWave(address indexed from, uint256 timestamp, string message);

    // Waveという構造体を作成(カスタマイズ可能)
    struct Wave {
        address waver; //「wave」を送ったユーザーのアドレス
        string message; // ユーザーが送ったメッセージ
        uint256 timestamp; // ユーザーが「wave」を送った時刻
        uint256 seed; // 乱数生成のためのシード（種）
    }

    // 構造体の配列を格納するための変数wavesを宣言(これで、ユーザーが送ってきたすべての「wave」を保持することができる)
    Wave[] private _waves;

    // [スパム防止]"address => uint mapping"は、アドレスと数値を関連付ける
    mapping(address => uint256) public lastWavedAt;

    // constructor()は、コントラクトがデプロイされた瞬間に一度だけ呼ばれる関数
    // payableを加えることで、コントラクトに送金機能を実装
    constructor() payable {
        console.log("We have been constructed!");
        //初期シードを設定
        _seed = (block.timestamp + block.prevrandao) % 100;
    }

    // _message(ユーザーがフロント側から送信するメッセージ)を要求するようにwave関数を更新。
    function wave(string memory _message) public {
        // [スパム防止]waveを送る間隔は15分開けなければいけない
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "Wait 15m"
        );

        // [スパム防止]ユーザーの現在のタイムスタンプを更新する
        lastWavedAt[msg.sender] = block.timestamp;


        _totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        /*
         * ユーザーのために乱数を生成
         */
        // 'prevrandao' is a smart contract feature that generates a random number
        _seed = (block.prevrandao + block.timestamp + _seed) % 100;

        _waves.push(Wave(msg.sender, _message, block.timestamp, _seed));

        console.log("Random # generated: %d", _seed);

        /*
         * ユーザーがETHを獲得する確率を50％に設定
         */
        if (_seed <= 50) {
            console.log("%s won!", msg.sender);

            /*
             * ユーザーにETHを送るためのコードは以前と同じ
             */
            uint256 prizeAmount = 0.0005 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        } else {
            console.log("%s did not win.", msg.sender);
		}

        emit NewWave(msg.sender, block.timestamp, _message);
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