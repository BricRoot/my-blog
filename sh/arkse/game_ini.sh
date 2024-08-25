#!/bin/bash

# Game.ini文件的路径
GAME_INI_PATH="ShooterGame/Saved/Config/LinuxServer/Game.ini"

# 备份原文件
cp "$GAME_INI_PATH" "${GAME_INI_PATH}.bak"

# 要设置的PlayerBaseStatMultipliers参数和值
PLAYER_STATS=(
    "PlayerBaseStatMultipliers[0]=${PLAYERBASESTATMULTIPLIERS0}"
    "PlayerBaseStatMultipliers[1]=${PLAYERBASESTATMULTIPLIERS1}"
    "PlayerBaseStatMultipliers[2]=${PLAYERBASESTATMULTIPLIERS2}"
    "PlayerBaseStatMultipliers[3]=${PLAYERBASESTATMULTIPLIERS3}"
    "PlayerBaseStatMultipliers[4]=${PLAYERBASESTATMULTIPLIERS4}"
    "PlayerBaseStatMultipliers[5]=${PLAYERBASESTATMULTIPLIERS5}"
    "PlayerBaseStatMultipliers[6]=${PLAYERBASESTATMULTIPLIERS6}"
    "PlayerBaseStatMultipliers[7]=${PLAYERBASESTATMULTIPLIERS7}"
    "PlayerBaseStatMultipliers[8]=${PLAYERBASESTATMULTIPLIERS8}"
    "PlayerBaseStatMultipliers[9]=${PLAYERBASESTATMULTIPLIERS9}"
    "PlayerBaseStatMultipliers[10]=${PLAYERBASESTATMULTIPLIERS10}"
    "PlayerBaseStatMultipliers[11]=${PLAYERBASESTATMULTIPLIERS11}"
    "PerLevelStatsMultiplier_Player[0]=${PERLEVELSTATSMULTIPLIER_PLAYER0}"
    "PerLevelStatsMultiplier_Player[1]=${PERLEVELSTATSMULTIPLIER_PLAYER1}"
    "PerLevelStatsMultiplier_Player[2]=${PERLEVELSTATSMULTIPLIER_PLAYER2}"
    "PerLevelStatsMultiplier_Player[3]=${PERLEVELSTATSMULTIPLIER_PLAYER3}"
    "PerLevelStatsMultiplier_Player[4]=${PERLEVELSTATSMULTIPLIER_PLAYER4}"
    "PerLevelStatsMultiplier_Player[5]=${PERLEVELSTATSMULTIPLIER_PLAYER5}"
    "PerLevelStatsMultiplier_Player[6]=${PERLEVELSTATSMULTIPLIER_PLAYER6}"
    "PerLevelStatsMultiplier_Player[7]=${PERLEVELSTATSMULTIPLIER_PLAYER7}"
    "PerLevelStatsMultiplier_Player[8]=${PERLEVELSTATSMULTIPLIER_PLAYER8}"
    "PerLevelStatsMultiplier_Player[9]=${PERLEVELSTATSMULTIPLIER_PLAYER9}"
    "PerLevelStatsMultiplier_Player[10]=${PERLEVELSTATSMULTIPLIER_PLAYER10}"
    "PerLevelStatsMultiplier_Player[11]=${PERLEVELSTATSMULTIPLIER_PLAYER11}"
    "PerLevelStatsMultiplier_DinoTamed[0]=${PERLEVELSTATSMULTIPLIER_DINOTAMED0}"
    "PerLevelStatsMultiplier_DinoTamed[1]=${PERLEVELSTATSMULTIPLIER_DINOTAMED1}"
    "PerLevelStatsMultiplier_DinoTamed[2]=${PERLEVELSTATSMULTIPLIER_DINOTAMED2}"
    "PerLevelStatsMultiplier_DinoTamed[3]=${PERLEVELSTATSMULTIPLIER_DINOTAMED3}"
    "PerLevelStatsMultiplier_DinoTamed[4]=${PERLEVELSTATSMULTIPLIER_DINOTAMED4}"
    "PerLevelStatsMultiplier_DinoTamed[7]=${PERLEVELSTATSMULTIPLIER_DINOTAMED7}"
    "PerLevelStatsMultiplier_DinoTamed[8]=${PERLEVELSTATSMULTIPLIER_DINOTAMED8}"
    "PerLevelStatsMultiplier_DinoTamed[9]=${PERLEVELSTATSMULTIPLIER_DINOTAMED9}"
    "PerLevelStatsMultiplier_DinoWild[0]=${PERLEVELSTATSMULTIPLIER_DINOWILD0}"
    "PerLevelStatsMultiplier_DinoWild[1]=${PERLEVELSTATSMULTIPLIER_DINOWILD1}"
    "PerLevelStatsMultiplier_DinoWild[2]=${PERLEVELSTATSMULTIPLIER_DINOWILD2}"
    "PerLevelStatsMultiplier_DinoWild[3]=${PERLEVELSTATSMULTIPLIER_DINOWILD3}"
    "PerLevelStatsMultiplier_DinoWild[7]=${PERLEVELSTATSMULTIPLIER_DINOWILD7}"
    "PerLevelStatsMultiplier_DinoWild[8]=${PERLEVELSTATSMULTIPLIER_DINOWILD8}"
    "PerLevelStatsMultiplier_DinoWild[9]=${PERLEVELSTATSMULTIPLIER_DINOWILD9}"
    "DinoTurretDamageMultiplier"=${DINOTURRETDAMAGEMULTIPLIER}
    "AllowRaidDinoFeeding"=${ALLOWRAIDDINOFEEDING}
)

# 检查Game.ini文件是否存在，如果不存在则创建
if [ ! -f "$GAME_INI_PATH" ]; then
    mkdir -p "$(dirname "$GAME_INI_PATH")"  # 创建目录（如果不存在）
    touch "$GAME_INI_PATH"  # 创建文件
fi

# 检查Game.ini的首行是否为[/script/shootergame.shootergamemode]
FIRST_LINE=$(head -n 1 "$GAME_INI_PATH")

if [ "$FIRST_LINE" != "[/script/shootergame.shootergamemode]" ]; then
    # 如果首行不是，检查文件中是否有该行
    if grep -q "^\[/script/shootergame.shootergamemode\]" "$GAME_INI_PATH"; then
        # 如果文件中有该行，删除该行并将其添加到首行
        sed -i "/^\[/script/shootergame.shootergamemode\]/d" "$GAME_INI_PATH"
    fi
    # 添加到首行
    sed -i "1i [/script/shootergame.shootergamemode]" "$GAME_INI_PATH"
fi

# 处理PlayerBaseStatMultipliers参数的设置
for STAT in "${PLAYER_STATS[@]}"; do
    STAT_NAME="${STAT%%=*}"  # 获取参数名
    NEW_VALUE="${STAT#*=}"    # 获取参数值

    # 检查参数是否存在于Game.ini文件中
    if grep -q "^[^;#]*$STAT_NAME=" "$GAME_INI_PATH"; then
        # 如果参数存在，使用sed命令直接在文件中替换值
        sed -i "s/^[^;#]*$STAT_NAME[^=]*=.*/$STAT_NAME=$NEW_VALUE/" "$GAME_INI_PATH"
    else
        # 如果参数不存在，在文件末尾添加新的参数行
        echo "$STAT_NAME=$NEW_VALUE" >> "$GAME_INI_PATH"
    fi
done

# 保存首行内容
head -n 1 "$GAME_INI_PATH" > tmpfile

# 处理除首行外的内容，删除上面的重复变量行，保留最后一次出现的行
# 使用tac命令倒序内容，这样awk会保留第一次出现的变量行（即原文件中最后一个），然后再将其正序
tail -n +2 "$GAME_INI_PATH" | tac | awk -F= '!seen[$1]++ || $1 ~ /OverridePlayerLevelEngramPoints/' | tac >> tmpfile

# 替换原文件
mv tmpfile "$GAME_INI_PATH"

echo "Game.ini文件更新完成。"