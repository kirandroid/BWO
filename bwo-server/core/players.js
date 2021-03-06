var state;
var notifyAllOnRangeOfPlayer;
var notifyAllOnRangeOfArea;
var enemysController;
var notifyAll;
var removeSocket;

export function setup(mState, mNotifyAllOnRangeOfPlayer, mNotifyAllOnRangeOfArea, mEnemysController, mNotifyAll, mRemoveSocket) {
    state = mState;
    notifyAllOnRangeOfPlayer = mNotifyAllOnRangeOfPlayer;
    notifyAllOnRangeOfArea = mNotifyAllOnRangeOfArea;
    enemysController = mEnemysController;
    notifyAll = mNotifyAll;
    removeSocket = mRemoveSocket;
}

export function updatePlayer(command, state, notifyAllOnRangeOfPlayer) {
    const playerId = command.playerId
    var playerFound = state.players[playerId]

    if (playerFound != undefined) {
        state.players[command.playerId] = {
            ...state.players[command.playerId],
            ...command,
        };

        notifyAllOnRangeOfPlayer({
            type: 'onPlayerUpdate',
            ...state.players[command.playerId]
        }, true)
    }
}

export function movePlayer(command) {
    const playerId = command.playerId
    var playerFound = state.players[playerId]

    if (playerFound != undefined) {

        state.players[command.playerId] = {
            ...state.players[command.playerId],
            ...command,
        };

        notifyAllOnRangeOfPlayer({
            type: 'onMove',
            ...state.players[command.playerId]
        }, true)
    }
    else {
        console.log(`> player ${playerId} not found when trying to move him`)
    }

    enemysController.spawnEnemyLoop(playerFound, state.enemys, (enemyListAroundPlayer) => {
        //enemy created 
        notifyAllOnRangeOfPlayer({
            type: 'onEnemysWalk',
            playerId: command.playerId,
            enemys: enemyListAroundPlayer
        })
    })
}

function addPlayer(command) {
    const playerId = command.playerId
    state.players[playerId] = {
        name: command.name,
        ...command,
        x: command.x,
        y: command.y,
    }

    notifyAllOnRangeOfPlayer({
        type: 'add-player',
        ...command
    })
}

export function removePlayer(command) {
    const playerId = command.playerId

    if (state.players[playerId] != undefined) {
        const playerName = state.players[playerId].name

        delete state.players[playerId]
        notifyAll({
            type: 'remove-player',
            playerId: playerId,
            name: playerName
        })
        removeSocket(playerId);

        var totalPlayers = Object.keys(state.players).length
        var totalEnemys = Object.keys(state.enemys).length
        console.log(`> Players Online: ${totalPlayers} and ${totalEnemys} Enemys Spawned`)
    }
    else {
        console.log(`can't remove player because it dosen't exist anymore`)
    }
}

export function logPlayer(command) {
    const playerId = command.playerId
    const playerName = command.name
    var playerFound = state.players[playerId]

    if (playerFound != undefined) {
        console.log(`> Player ${playerId} already conneced`)
        return;
    } else {
        console.log(`> Player ${playerId} not found, creating new player '${playerName}'`)
        addPlayer({ ...command })
        var totalPlayers = Object.keys(state.players).length
        var totalEnemys = Object.keys(state.enemys).length
        console.log(`> Players Online: ${totalPlayers} and ${totalEnemys} Enemys Spawned`)
        //playerFound = state.players[playerId]
    }
}

export function respawn(command) {
    const playerId = command.playerId
    var playerFound = state.players[playerId]
    var dead_body_point = {
        x: state.players[command.playerId].x,
        y: state.players[command.playerId].y
    }

    if (playerFound != undefined) {
        state.players[command.playerId] = {
            ...state.players[command.playerId],
            ...command,
        };
        console.log('respawn');

        //nofiy all players on where my body really is now incluring myself
        notifyAllOnRangeOfPlayer({
            type: 'onPlayerUpdate',
            ...state.players[command.playerId]
        }, false)

        //nofity all players around the deadbody that this player will respawn
        notifyAllOnRangeOfArea({
            type: 'onPlayerUpdate',
            point: dead_body_point,
            ...state.players[command.playerId]
        })
    }
}

export function attackEnemy(command) {
    const mPlayer = state.players[command.playerId];
    const mEnemy = state.enemys[command.enemyId];

    if (mPlayer != undefined && mEnemy != undefined) {
        mEnemy.hp -= command.damage;

        notifyAllOnRangeOfPlayer({
            type: 'onPlayerAttackEnemy',
            ...command,
            enemyHp: mEnemy.hp,
        })

        if (mEnemy.hp <= 0) {
            delete state.enemys[command.enemyId]
        }
    }
}

export function hitTree(command) {
    notifyAllOnRangeOfPlayer({
        ...command,
        type: 'onTreeHit',
    })
}