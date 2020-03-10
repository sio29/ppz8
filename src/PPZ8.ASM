;------------------------------------------------------------------------------
;		86B,WSS,SB PCM8
;		- PPZ8.COM -			KGB-1373 UKKY
;------------------------------------------------------------------------------
		.186
		INCLUDE	HEAD.ASM
;******************************************************************************
;		EQU
;******************************************************************************
_PPZ8_VER	EQU	<'1.07'>	;ﾊﾞｰｼﾞｮﾝ

RNUM_DEF_86B	EQU	3		;
RATE_DEF_86B	EQU	16540		;
VNUM_DEF_86B	EQU	12		;
VOL_DEF_86B	EQU	12		;

RNUM_DEF_WSS	EQU	3		;
RATE_DEF_WSS	EQU	16000		;
VNUM_DEF_WSS	EQU	12		;
VOL_DEF_WSS	EQU	56		;

RNUM_DEF_SB	EQU	3		;
RATE_DEF_SB	EQU	16540		;
VNUM_DEF_SB	EQU	12		;
VOL_DEF_SB	EQU	56		;

PCM_FUNC	EQU	7FH	;PPZ.COM のファンクション番号
X_N0		EQU	80H	;Xn の初期値
DELTA_N0	EQU	127	;DELTA_N の初期値
DTA_VOL		EQU	100H	;DTAの大きさ
FIFO_DEF_VOL	EQU	80H*2	;FIFOのデェフォルトの大きさ

;PVIデータのフォーマット
PVI_NUM_MAX	EQU	00BH	;PVIデータの定義数
PVI_TBL_TOP	EQU	010H	;PVIテーブルの先頭
PVI_DATA_TOP	EQU	210H	;ADPCMデータの先頭
PZI_NUM_MAX	EQU	00BH	;PZIデータの定義数
PZI_TBL_TOP	EQU	020H	;PZIテーブルの先頭
PZI_DATA_TOP	EQU	920H	;PCMデータの先頭
PCME_DATA_VOL	EQU	920H	;ヘッダーの展開後のデータの大きさ

PCM_CNL_MAX	EQU	8	;PCMのﾁｬﾈﾙ数
;ﾁｬﾈﾙごとのワーク
PCM_ADD_L	EQU	02	;2byte アドレス増加量 LOW
PCM_ADD_H	EQU	04	;2byte アドレス増加量 HIGH
PCM_ADDS_L	EQU	06	;2byte アドレス増加量 LOW （元の値）
PCM_ADDS_H	EQU	08	;2byte アドレス増加量 HIGH（元の値）
PCM_SORC_F	EQU	10	;2byte 元データの再生レート
PCM_EMS_HANDLE	EQU	12	;2byte EMSハンドル
PCM_FLG		EQU	14	;2byte 再生フラグ
PCM_VOL		EQU	16	;2byte ボリューム
PCM_PAN		EQU	18	;2byte PAN
PCM_NUM		EQU	20	;2byte PCM番号
PCM_LOOP_FLG	EQU	22	;2byte ループ使用フラグ
PCM_NOW_XOR	EQU	24	;2byte 小数点部分（MSBが上位、下位4bitを示す）
PCM_NOW_OFF	EQU	26	;2byte 現在のオフセット
PCM_NOW_PAGE	EQU	28	;2byte 現在のEMSページ
PCM_END_OFF	EQU	30	;2byte 現在の終了アドレスのオフセット
PCM_END_PAGE	EQU	32	;2byte 現在の終了アドレスのEMSページ
PCM_END_SPAGE	EQU	34	;2byte 本当の終了アドレスのオフセット
PCM_END_SOFF	EQU	36	;2byte 本当の終了アドレスのEMSページ
PCM_LOOP_OFF	EQU	38	;2byte ループ開始アドレスのオフセット
PCM_LOOP_PAGE	EQU	40	;2byte ループ開始アドレスのEMSページ
PCM_LOOP_START	EQU	42	;4byte リニアなループ開始アドレス
PCM_LOOP_END	EQU	48	;4byte リニアなループ終了アドレス

PCM_WORK_VOL	EQU	52	;ワークの大きさ
PCM_WORK_AVOL	EQU	PCM_WORK_VOL*PCM_CNL_MAX	;ﾁｬﾈﾙワーク全体
;------------------------------------------------------------------------------
;	サービス割り込みビット定義
;------------------------------------------------------------------------------
SERVICE_NON	equ	00h	; 呼び出しなし
SERVICE_START	equ	01h	; 演奏開始時
SERVICE_LOOP	equ	02h	; ループ時
SERVICE_STOP	equ	04h	; 演奏停止時
SERVICE_ERROR	equ	08h	; エラー発生時
SERVICE_EVERY	equ	10h	; 毎回の割り込み
SERVICE_SLOW	equ	20h	; 低速一定間隔
SERVICE_RESERVE	equ	40h	; 未使用
SERVICE_REQUEST	equ	80h	; リクエスト要求

REQUEST_REMOVE	equ	80h	; 常駐解除要求
;------------------------------------------------------------------------------
;	タスク制御定義
;------------------------------------------------------------------------------
TASK_ASIN	equ	0	; タスク割り当て
TASK_DEASIN	equ	1	; タスク割り当て解除
TASK_CHECK	equ	2	; タスクチェック
TASK_STOP	equ	3	; タスク動作停止
TASK_START	equ	4	; タスク動作開始
TASK_CHMODE	equ	5	; 動作モード変更
TASK_CHADDR	equ	6	; 動作アドレス変更
TASK_CHNAME	equ	7	; 識別名変更
TASK_SEND	equ	8	; コマンド送信
;------------------------------------------------------------------------------
;		FMPバージョン
;------------------------------------------------------------------------------
FMP1		EQU	404	;FMPのﾊﾞｰｼﾞｮﾝ
;------------------------------------------------------------------------------
;		CPU番号
;------------------------------------------------------------------------------
_V30		EQU	00	;V30だ
_286		EQU	01	;286だ
_386		EQU	02	;386だ
_486		EQU	03	;486以上だ
;------------------------------------------------------------------------------
;		ﾎﾞｰﾄﾞの種類
;------------------------------------------------------------------------------
_86B		EQU	00	;86ﾎﾞｰﾄﾞだ
_WSS		EQU	01	;WSSだ
_SB		EQU	02	;ｻｳﾝﾄﾞﾌﾞﾗｽﾀｰだ
;------------------------------------------------------------------------------
;		ﾄﾞﾗｲﾊﾞｰの種類
;------------------------------------------------------------------------------
_FMP_F		EQU	01	;FMPだ
_MDZ_F		EQU	02	;MDZだ
_PMD_F		EQU	03	;PMDだ
;******************************************************************************
;		マクロ
;******************************************************************************
;XMSのコールファンクション
_XMS		MACRO	FUNC
		MOV	AH,FUNC
		CALL	DWORD PTR CS:[XMS_ADR]
		ENDM

;GDTのテーブル
DESC		STRUC
LIMIT1		DW	0		;LIMIT 0-15
BASE1		DW	0		;BASE 0-15
BASE2		DB	0		;BASE 16-23
		DB	00000000B
		;	|||||||`-- A  ｱｸｾｽﾋﾞｯﾄ(無視)
		;	||||||`--      W ﾗｲﾄ          |  R ﾘｰﾄﾞ
		;	|||||`---      ED ｽﾀｯｸ        |  C ﾚﾍﾞﾙﾁｪｯｸ
		;	||||`---- TYPE.E=0 ﾃﾞｰﾀｾｸﾞﾒﾝﾄ |  E=1 ｺｰﾄﾞｾｸﾞﾒﾝﾄ
		;	|||`-- S  0:ｼｽﾃﾑ/ｹﾞｰﾄｾｸﾞﾒﾝﾄ / 1:ﾒﾓﾘｾｸﾞﾒﾝﾄ
		;	|``-- DPL  ﾚﾍﾞﾙ
		;	`-- P  0:ﾒﾓﾘに存在しない / 1:する
		DB	00000000B
		;	|| |````--  limit 16-19
		;	|| `-- AVL (無視)
		;	|`-- D ﾓｰﾄﾞ 0:use16 / 1:use32
		;	`-- G ｻｲｽﾞ 0:1byte / 1:4kbyte
BASE3		DB	0		; base 24 - 31		
DESC		ENDS

;セレクタ値
SEG_NULL	EQU	00H	;
SEG_FLAT	EQU	08H	;
;******************************************************************************
;		レジスタインデックス
;******************************************************************************
_FLAGS		EQU	+22		;
_AX		EQU	+16		;
_BX		EQU	+14		;
_CX		EQU	+12		;
_DX		EQU	+10		;
_SI		EQU	+08		;
_DI		EQU	+06		;
_BP		EQU	+04		;
_DS		EQU	+02		;
_ES		EQU	+00		;
;******************************************************************************
;		MACRO
;******************************************************************************
;=======================================
;	SBﾏｸﾛ
;=======================================
SB_MIX_ADR	EQU	24H		;ミキサーチップアドレス
SB_MIX_DAT	EQU	25H		;ミキサーチップデータ
SB_DSP_RST	EQU	26H		;DSP リセット I/O
SB_DSP_RDAT	EQU	2AH		;DSP リードデータ
SB_DSP_WDAT	EQU	2CH		;DSP ライトデータ
SB_DSP_STS	EQU	2CH		;DSP Busy フラグ
SB_DSP_ASTS	EQU	2EH		;DSP ステータス

SBDSP_IN	MACRO
		CALL	SB_DSP_IN
		ENDM
SBDSP_OUT	MACRO	DAT
		MOV	AL,DAT
		CALL	SB_DSP_OUT
		ENDM
SBMIX_IN	MACRO	ADR
		MOV	AH,ADR
		CALL	SB_MIX_IN
		ENDM
SBMIX_OUT	MACRO	ADR,DAT
		MOV	AH,ADR
		MOV	AL,DAT
		CALL	SB_MIX_OUT
		ENDM
;=======================================
;	OPN_WAIT
;=======================================
_IN_WAIT	MACRO
		REPT	5
		OUT	5FH,AL
		ENDM
		ENDM
;******************************************************************************
;		コードセグメント
;******************************************************************************
CODE		SEGMENT	PUBLIC	USE16
		ASSUME	CS:CODE,DS:CODE
		ORG	100H
START:
		JMP	COMMAND_LINE	;マンドライン解析へ
;******************************************************************************
;		INT7FH MAIN
;				IN	AH	ファンクション番号
;******************************************************************************
INT7FH:
		JMP	INT7FH_01
_PSGPCMZ	DB	'PPZ8',0
_PSGPCMZ_L	EQU	$-_PSGPCMZ
_PSGPCMZ_VER	DB	_PPZ8_VER
		DB	0
INT7FH_01:
		CMP	AH,INT7FH_MAX
		JAE	INT7FH_SKIP
		CLI
		CMP	CS:INT7FH_FLG,0			;多重ﾁｪｯｸ
		JNZ	INT7FH_SKIP
		MOV	CS:INT7FH_FLG,1
		STI
		;
		CLD
		_PUSH	AX,BX,CX,DX,SI,DI,BP,DS,ES
		MOV	CS:PUSH_REG,SP
		MOV	BX,SP
		AND	WORD PTR SS:[BX+_FLAGS],0FFFEH	;CARRYのクリア
		;
		XOR	BX,BX
		MOV	BL,AH
		SHL	BX,1
		CALL	CS:[BX+INT7FH_TBL]
		_POP	AX,BX,CX,DX,SI,DI,BP,DS,ES
		CLI
		MOV	CS:INT7FH_FLG,0
INT7FH_SKIP:
		IRET
INT7FH_ERR:
		MOV	BP,CS:[PUSH_REG]	;キャリーフラグのセット
		OR	WORD PTR [BP+_FLAGS],0001H
		RET
DUMMY_COM:
		RET
INT7FH_FLG	DB	0			;再入ﾌﾗｸﾞ
;******************************************************************************
;		INT7FHｺﾏﾝﾄﾞﾃｰﾌﾞﾙ
;******************************************************************************
INT7FH_TBL	LABEL	WORD
	DW	PCM_INIT_COM		;00H 初期化
	DW	PCM_PLAY_COM		;01H PCM 発音
	DW	PCM_STOP_COM		;02H PCM 停止
	DW	PVI_LOAD_COM		;03H PVI/PZIﾌｧｲﾙの読み込み
	DW	STATUS_GET		;04H ｽﾃｰﾀｽの読み込み
	DW	DUMMY_COM		;05H
	DW	DUMMY_COM		;06H
	DW	PCM_VOL_SET		;07H ﾎﾞﾘｭｰﾑ設定
	DW	DUMMY_COM		;08H
	DW	DUMMY_COM		;09H
	DW	DUMMY_COM		;0AH
	DW	PCM_ONTEI_SET		;0BH 音程周波数の設定
	DW	DUMMY_COM		;0CH
	DW	DUMMY_COM		;0DH
	DW	PCM_LOOP_SET		;0EH ﾙｰﾌﾟﾎﾟｲﾝﾀの設定
	DW	PCM_CONV_INIT		;0FH ADPCM>PCMの初期化
	DW	PCM_CONV_SUB		;10H ADPCM>PCM変換
	DW	DUMMY_COM		;11H
	DW	PCM_ALL_STOP		;12H (PPZ8)全停止
	DW	PCM_PAN_SET		;13H (PPZ8)PAN指定
	DW	RATE_SET2		;14H (PPZ8)ﾚｰﾄ設定
	DW	SORC_RATE_SET		;15H (PPZ8)元ﾃﾞｰﾀ周波数設定
	DW	PCM_AVOL_SET		;16H (PPZ8)全体ﾎﾞﾘﾕｰﾑの設定
	DW	PCMTMP_SET		;17H PCMﾃﾝﾎﾟﾗﾘ設定
	DW	ADPCM_EM_SET		;18H (PPZ8)ADPCMエミュレート
	DW	REMOVE_FSET		;19H (PPZ8)常駐解除ﾌﾗｸﾞ設定
	DW	FIFOBUFF_SET		;1AH (PPZ8)FIFOﾊﾞｯﾌｧの変更
	DW	RATE_SET		;1BH (PPZ8)WSS詳細ﾚｰﾄ設定
INT7FH_MAX	EQU	($-INT7FH_TBL)/2
;******************************************************************************
;		PCM初期化
;******************************************************************************
PCM_INIT_COM:
		PUSHF
		CLI
		CALL	WORK_INIT		;ﾜｰｸ初期化
		CALL	BD_PCM_STOP		;PCMの停止
		POPF
		RET
;******************************************************************************
;		再生レート設定
;				IN	DX	再生レート番号
;******************************************************************************
RATE_SET:
		MOV	BX,CS
		MOV	DS,BX
		;
		XOR	BX,BX			;設定できるﾚｰﾄ番号の
		MOV	BL,BD_FLG		;最大値を得る
		SHL	BX,1
		MOV	BX,[BX+BD_RATE_TBL]
		MOV	BX,[BX]
		CMP	DX,BX
		JAE	INT7FH_ERR		;設定値外ｴﾗｰ
		MOV	PCM_RATE,DL
		CALL	RATE_SET_SUB
		;
		RET
	;=======================================
	;	再生ﾚｰﾄ設定
	;=======================================
RATE_SET_SUB:
		XOR	BX,BX			;ﾚｰﾄ番号から再生ﾚｰﾄを求める
		MOV	BL,BD_FLG
		SHL	BX,1
		MOV	DI,[BX+BD_RATE_TBL]
		XOR	BX,BX
		MOV	BL,PCM_RATE
		SHL	BX,1
		MOV	BX,[DI+BX+2]
		MOV	DIST_F,BX
		;
		MOV	DI,OFFSET PCM_WORK	;全ﾁｬﾈﾙの音程調整
		MOV	CX,PCM_CNL_MAX
RATE_SETS_01:
		PUSH	CX
		MOV	CX,[DI+PCM_ADDS_L]
		MOV	DX,[DI+PCM_ADDS_H]
		CALL	ONTEI_SET_SUB
		POP	CX
		ADD	DI,PCM_WORK_VOL
		LOOP	RATE_SETS_01
		;
		CALL	BD_RATE_SET		;ﾎﾞｰﾄﾞのﾚｰﾄ設定
		RET
;******************************************************************************
;		86B互換のﾚｰﾄ番号で設定
;******************************************************************************
RATE_SET2:
		MOV	BX,CS
		MOV	DS,BX
		;
		CMP	DX,8
		JAE	INT7FH_ERR
		MOV	PCM_RATE_WK,DL		;86B互換のﾚｰﾄ番号
	;=======================================
	;	再生ﾚｰﾄ設定（86B互換）
	;=======================================
RATE_SET_SUB2:
		XOR	DX,DX
		MOV	DL,PCM_RATE_WK
		XOR	BX,BX			;設定できるﾚｰﾄ番号の
		MOV	BL,BD_FLG		;最大値を得る
		SHL	BX,1
		MOV	DI,[BX+BD_RATE_TBL2]
		ADD	DI,DX
		MOV	AL,[DI]
		MOV	PCM_RATE,AL
		CALL	RATE_SET_SUB
		;
		RET
;******************************************************************************
;		ワーク初期化
;******************************************************************************
WORK_INIT:
		CLD
		MOV	AX,CS			;ワーク初期化
		MOV	DS,AX
		MOV	ES,AX
		;
		MOV	DI,OFFSET PCM_WORK	;ワークを0クリア
		MOV	CX,PCM_WORK_VOL*PCM_CNL_MAX/2
		XOR	AX,AX
		REP	STOSW
		;
		MOV	BP,1
		XOR	DX,DX
		MOV	DI,OFFSET PCM_WORK
		MOV	CX,PCM_CNL_MAX
WORK_INIT_04:
		MOV	[DI+PCM_ADD_H],BP
		MOV	[DI+PCM_ADD_L],DX
		MOV	[DI+PCM_ADDS_H],BP
		MOV	[DI+PCM_ADDS_L],DX
		MOV	WORD PTR [DI+PCM_SORC_F],16000	;元データの再生レート
		MOV	WORD PTR [DI+PCM_PAN],5		;PAN中心
		MOV	BYTE PTR [DI+PCM_VOL],8		;ボリュームデフォルト
		ADD	DI,PCM_WORK_VOL
		LOOP	WORK_INIT_04
		;
		;MOV	PCME_WORK0+PVI_NUM_MAX,0	;PVIのMAXを０にする
		RET
;******************************************************************************
;		PCM発音
;			入力	AL	PCM ﾁｬﾈﾙ
;				DX	PCM 番号
;				bit15=0	PCM0
;				bit15=1	PCM1
;				ADPCMエミュレート時
;				SI	STARTアドレス
;				DI	ENDアドレス
;******************************************************************************
PCM_PLAY_COM:
		CMP	AL,PCM_CNL_MAX
		JAE	CNL_OVER
		;
		AND	DH,80H
		MOV	CS:_PCM_NUM,DX
		;
		MOV	BX,CS
		MOV	DS,BX
		MOV	ES,BX
		MOV	CX,SI
		;
		;PVIの定義数より大きいとスキップ
		MOV	NOW_PCM_NUM,0
		MOV	SI,OFFSET PCME_WORK0
		OR	DX,DX
		JNS	PCM_PLAY_01
		MOV	NOW_PCM_NUM,1
		MOV	SI,OFFSET PCME_WORK1
PCM_PLAY_01:
		CMP	AL,7
		JNZ	PCM_PLAY_02
		CMP	ADPCM_EM_FLG,0
		JZ	PCM_PLAY_02
		OR	DL,DL
		JS	PCM_PLAY_02
		MOV	SI,CX
		INC	DI
		SUB	DI,SI
		MOV	BX,OFFSET PCME_DUMMY
		XOR	CX,CX
		REPT	6
		SHL	SI,1
		RCL	CX,1
		ENDM
		MOV	[BX+0],SI
		MOV	[BX+2],CX
		XOR	CX,CX
		REPT	6
		SHL	DI,1
		RCL	CX,1
		ENDM
		MOV	[BX+4],DI
		MOV	[BX+6],CX
		JMP	PCM_PLAY_03
PCM_PLAY_02:
		AND	DX,7FH
		MOV	BL,[SI+PVI_NUM_MAX]
		XOR	BH,BH
		CMP	DX,BX
		;;;JAE	PCM_PLAY_SKIP
		;
		MOV	BX,DX			;BX 音色テーブルアドレス
		SHL	BX,1
		SHL	DX,4
		ADD	DX,BX
		LEA	BX,[SI+PZI_TBL_TOP]
		ADD	BX,DX
PCM_PLAY_03:
		CLI				;割り込み禁止
		MOV	AH,PCM_WORK_VOL		;DI にワークバッファ
		MUL	AH
		ADD	AX,OFFSET PCM_WORK
		MOV	DI,AX
		MOV	WORD PTR [DI+PCM_FLG],1		;再生開始
		MOV	WORD PTR [DI+PCM_NOW_XOR],0	;小数点部
		MOV	DX,_PCM_NUM
		MOV	[DI+PCM_NUM],DX			;音色番号
		;
		CMP	EMS_XMS_FLG,0		;EMSかXMSか？
		JNZ	PCM_PLAY_08
		;
		;EMSを使用してる場合
		MOV	AX,EMS_HANDLE0
		CMP	NOW_PCM_NUM,0
		JZ	PCM_PLAY_07
		MOV	AX,EMS_HANDLE1
PCM_PLAY_07:
		MOV	[DI+PCM_EMS_HANDLE],AX
		;
		MOV	CX,[BX+0]
		MOV	DX,[BX+2]
		CALL	PAGE_OFF_GET
		MOV	[DI+PCM_NOW_OFF],AX	;開始アドレス
		MOV	[DI+PCM_NOW_PAGE],CX	;開始ページ
		;
		MOV	CX,[BX+0]
		MOV	DX,[BX+2]
		ADD	CX,[BX+4]
		ADC	DX,[BX+6]
		CALL	PAGE_OFF_GET
		MOV	[DI+PCM_END_SOFF],AX	;終了アドレス
		MOV	[DI+PCM_END_SPAGE],CX	;終了ページ
		;
		CMP	WORD PTR [DI+PCM_LOOP_FLG],0
		JNZ	PCM_PLAY_20
		;
		MOV	[DI+PCM_END_OFF],AX	;終了アドレス
		MOV	[DI+PCM_END_PAGE],CX	;終了ページ
		JMP	PCM_PLAY_10
		;XMSを使用してる場合
PCM_PLAY_08:
		MOV	CX,[BX+0]
		MOV	DX,[BX+2]
		CALL	XMS_OFF_GET
		MOV	[DI+PCM_NOW_OFF+0],CX	;開始アドレス
		MOV	[DI+PCM_NOW_OFF+2],DX	;開始アドレス
		;
		MOV	CX,[BX+0]
		MOV	DX,[BX+2]
		ADD	CX,[BX+4]
		ADC	DX,[BX+6]
		CALL	XMS_OFF_GET
		MOV	[DI+PCM_END_SOFF+0],CX	;終了アドレス
		MOV	[DI+PCM_END_SOFF+2],DX	;終了アドレス
		;
		CMP	WORD PTR [DI+PCM_LOOP_FLG],0
		JNZ	PCM_PLAY_30
		;
		MOV	[DI+PCM_END_OFF+0],CX	;終了アドレス
		MOV	[DI+PCM_END_OFF+2],DX	;終了アドレス
PCM_PLAY_10:
		CMP	_PCM_FLG,0		;再生されていない場合
		JNZ	PCM_PLAY_19
		;
		CALL	BD_PCM_PLAY		;PCM初期化
PCM_PLAY_19:
		STI
PCM_PLAY_SKIP:
		RET
		;EMSを使用してる場合
PCM_PLAY_20:
		MOV	CX,[DI+PCM_LOOP_START+0]
		MOV	DX,[DI+PCM_LOOP_START+2]
		CALL	PCM_PLAY_40
		SBB	CX,0
		SBB	DX,0
		ADD	CX,[BX+0]
		ADC	DX,[BX+2]
		CALL	PAGE_OFF_GET
		MOV	[DI+PCM_LOOP_OFF],AX	;ループ開始アドレス
		MOV	[DI+PCM_LOOP_PAGE],CX	;ループ開始ページ
		;
		MOV	CX,[DI+PCM_LOOP_END+0]
		MOV	DX,[DI+PCM_LOOP_END+2]
		CALL	PCM_PLAY_40
		ADD	CX,[BX+0]
		ADC	DX,[BX+2]
		CALL	PAGE_OFF_GET
		MOV	[DI+PCM_END_OFF],AX	;終了アドレス
		MOV	[DI+PCM_END_PAGE],CX	;終了ページ
		;
		JMP	PCM_PLAY_10
		;XMSを使用してる場合
PCM_PLAY_30:
		MOV	CX,[DI+PCM_LOOP_START+0]
		MOV	DX,[DI+PCM_LOOP_START+2]
		CALL	PCM_PLAY_40
		SBB	CX,0
		SBB	DX,0
		ADD	CX,[BX+0]
		ADC	DX,[BX+2]
		CALL	XMS_OFF_GET
		MOV	[DI+PCM_LOOP_OFF+0],CX	;ループ開始アドレス
		MOV	[DI+PCM_LOOP_OFF+2],DX	;ループ開始アドレス
		;
		MOV	CX,[DI+PCM_LOOP_END+0]
		MOV	DX,[DI+PCM_LOOP_END+2]
		CALL	PCM_PLAY_40
		ADD	CX,[BX+0]
		ADC	DX,[BX+2]
		CALL	XMS_OFF_GET
		MOV	[DI+PCM_END_OFF+0],CX	;ループ終了アドレス
		MOV	[DI+PCM_END_OFF+2],DX	;ループ終了アドレス
		;
		JMP	PCM_PLAY_10
PCM_PLAY_40:
		CMP	DX,[BX+6]
		JB	PCM_PLAY_41
		CMP	CX,[BX+4]
		JB	PCM_PLAY_41
		MOV	CX,[BX+4]
		MOV	DX,[BX+6]
		STC
		RET
PCM_PLAY_41:
		CLC
		RET
	;=======================================
	;	EMSのページとオフセットを求める
	;		IN	DX:CX
	;		OUT	AX	PAGE
	;			CX	OFFSET
	;=======================================
PAGE_OFF_GET:
		MOV	AX,CX
		AND	AX,3FFFH
		REPT	14
		SHR	DX,1
		RCR	CX,1
		ENDM
		RET
	;=======================================
	;	XMSのオフセットを求める
	;		IN	DX:CX	オフセット
	;		OUT	DX:CX	リニアアドレス
	;=======================================
XMS_OFF_GET:
		CMP	NOW_PCM_NUM,0
		JNZ	XMS_OFF_GET_01
		ADD	CX,WORD PTR XMS_FRAME_ADR0+0
		ADC	DX,WORD PTR XMS_FRAME_ADR0+2
		RET
XMS_OFF_GET_01:
		ADD	CX,WORD PTR XMS_FRAME_ADR1+0
		ADC	DX,WORD PTR XMS_FRAME_ADR1+2
		RET
;******************************************************************************
;		PCM停止
;			入力	AL	PCMﾁｬﾈﾙ
;******************************************************************************
PCM_STOP_COM:
		CMP	AL,PCM_CNL_MAX
		JAE	CNL_OVER
		;
		MOV	BX,CS
		MOV	DS,BX
		MOV	AH,PCM_WORK_VOL		;DI ワークアドレス
		MUL	AH
		ADD	AX,OFFSET PCM_WORK
		MOV	DI,AX
		CLI
		MOV	WORD PTR [DI+PCM_FLG],0	;再生停止
		STI
		RET
;******************************************************************************
;		PCM音程周波数の決定
;			入力	AL	PCMﾁｬﾈﾙ
;				DX:CX	PCMの音程周波数
;					00008000H で元データと同じ周波数
;******************************************************************************
PCM_ONTEI_SET:
		CMP	AL,PCM_CNL_MAX
		JAE	CNL_OVER
		;
		MOV	BX,CS
		MOV	DS,BX
		;
		MOV	BX,AX
		MOV	AH,PCM_WORK_VOL		;DI ワークアドレス
		MUL	AH
		ADD	AX,OFFSET PCM_WORK
		MOV	DI,AX
		;
		CMP	BL,7			;CNL7?
		JNZ	PCM_ONTEI_S_01
		CMP	ADPCM_EM_FLG,0		;ADPCMエミュレート中？
		JZ	PCM_ONTEI_S_01
		;
		MOV	WORD PTR [DI+PCM_SORC_F],16000	;16KHz固定
		MOV	BP,CX			;BP:BX = DELTA_N x 8000H
		XOR	BX,BX
		SHR	BP,1
		RCR	BX,1
		MOV	CX,49BAH		;DX:CX = BP:BX / 49BAH
		;
		XOR	DX,DX
		MOV	AX,BP
		DIV	CX
		MOV	BP,AX
		MOV	AX,BX
		DIV	CX
		MOV	CX,AX
		MOV	DX,BP
PCM_ONTEI_S_01:
		CLI
		MOV	[DI+PCM_ADDS_L],CX
		MOV	[DI+PCM_ADDS_H],DX
		CALL	ONTEI_SET_SUB
		STI
		RET
ONTEI_SET_SUB:
	;=======================================
	;　再生周波数 : 元ADD_VOL = 元周波数 : 求めるADD_VOL
	;=======================================
		MOV	AX,[DI+PCM_SORC_F]	;BP:BX:CX = DX:CX x SORC_F
		MUL	DX
		MOV	BP,DX
		MOV	BX,AX
		MOV	AX,[DI+PCM_SORC_F]
		MUL	CX
		MOV	CX,AX
		ADD	BX,DX
		ADC	BP,0
		;
		XOR	DX,DX			;DX:CX = BP:BX:CX / DIST_F
		MOV	AX,BP
		DIV	DIST_F
		MOV	BP,AX
		MOV	AX,BX
		DIV	DIST_F
		MOV	BX,AX
		MOV	AX,CX
		DIV	DIST_F
		MOV	CX,AX
		MOV	DX,BX
	;=======================================
	;	ワーク設定
	;=======================================
		SHL	CX,1
		RCL	DX,1
		MOV	[DI+PCM_ADD_L],CX
		MOV	[DI+PCM_ADD_H],DX
		;
		RET
;******************************************************************************
;		ボリューム変更
;			入力	AL	PCMﾁｬﾈﾙ
;				DX	ﾎﾞﾘｭｰﾑ
;******************************************************************************
PCM_VOL_SET:
		CMP	AL,PCM_CNL_MAX
		JAE	CNL_OVER
		;
		MOV	BX,CS
		MOV	DS,BX
		;
		MOV	BX,AX
		MOV	AH,PCM_WORK_VOL		;DI ワークアドレス
		MUL	AH
		ADD	AX,OFFSET PCM_WORK
		MOV	DI,AX
		;
		CMP	BL,7			;CNL7?
		JNZ	PCM_VOL_SET_01
		CMP	ADPCM_EM_FLG,0		;ADPCMエミュレート中？
		JZ	PCM_VOL_SET_01
		MOV	BX,DX
		MOV	DL,[BX+ADPCM_EM_VOL]
PCM_VOL_SET_01:
		CLI
		MOV	[DI+PCM_VOL],DL
		STI
		RET
;******************************************************************************
;		ループ指定発音
;			入力	AL	PCMﾁｬﾈﾙ
;				DX:CX	ループ開始オフセット
;					-1でループ解除
;				DI:SI	ループ終了オフセット
;					-1でデフォルトでその音色の最後まで
;
;	ループ開始アドレス = 発音開始アドレス + ループ開始オフセット
;
;	ループ終了アドレス = 発音開始アドレス + ループ終了オフセット
;
;	○動作状況
;
;		発音開始アドレス
;			↓
;		ループ開始アドレス
;		　　↓　　　↑(ループする場合)
;		ループ終了アドレス
;			↓(ループしない場合)
;		発音停止アドレス
;
;******************************************************************************
PCM_LOOP_SET:
		CMP	AL,PCM_CNL_MAX
		JAE	CNL_OVER
		;
		CLI			;割り込み禁止
		MOV	BX,CS
		MOV	DS,BX
		;
		MOV	AH,PCM_WORK_VOL		;DI にワークバッファ
		MUL	AH
		ADD	AX,OFFSET PCM_WORK
		MOV	BX,AX
		;
		MOV	AX,CX
		AND	AX,DX
		CMP	AX,-1
		JZ	PCM_LPS_01
		;
		CMP	DI,DX
		JA	PCM_LPS_02
		JB	PCM_LPS_01
		CMP	SI,CX
		JA	PCM_LPS_02
PCM_LPS_01:
		MOV	WORD PTR [BX+PCM_LOOP_FLG],0
		MOV	AX,[BX+PCM_END_SOFF]	;本来の終了アドレス
		MOV	[BX+PCM_END_OFF],AX
		MOV	AX,[BX+PCM_END_SPAGE]
		MOV	[BX+PCM_END_PAGE],AX
		JMP	PCM_LPS_03
PCM_LPS_02:
		MOV	WORD PTR [BX+PCM_LOOP_FLG],1
		MOV	[BX+PCM_LOOP_START+0],CX
		MOV	[BX+PCM_LOOP_START+2],DX
		MOV	[BX+PCM_LOOP_END+0],SI
		MOV	[BX+PCM_LOOP_END+2],DI
PCM_LPS_03:
		STI			;割り込み許可
		RET
;******************************************************************************
;		PAN設定
;			入力	AL	PCM ﾁｬﾈﾙ
;				DX	PAN (0:無音,1:Left,2:Right,3:CENTER)
;******************************************************************************
PCM_PAN_SET:
		CMP	AL,PCM_CNL_MAX
		JAE	CNL_OVER
		;
		MOV	BX,CS
		MOV	DS,BX
		;
		MOV	BX,AX
		MOV	AH,PCM_WORK_VOL		;DI ワークアドレス
		MUL	AH
		ADD	AX,OFFSET PCM_WORK
		MOV	DI,AX
		;
		CMP	BL,7			;CNL7?
		JNZ	PCM_PAN_SET_01
		CMP	ADPCM_EM_FLG,0		;ADPCMエミュレート中？
		JZ	PCM_PAN_SET_01
		MOV	BX,DX
		MOV	DL,[BX+ADPCM_EM_PAN]
PCM_PAN_SET_01:
		CLI
		MOV	[DI+PCM_PAN],DL
		STI
		RET
;******************************************************************************
;		元周波数設定
;			入力	AL	PCMﾁｬﾈﾙ
;				DX	元周波数
;******************************************************************************
SORC_RATE_SET:
		CMP	AL,PCM_CNL_MAX
		JAE	CNL_OVER
		;
		MOV	BX,CS
		MOV	DS,BX
		MOV	AH,PCM_WORK_VOL		;DI ワークアドレス
		MUL	AH
		ADD	AX,OFFSET PCM_WORK
		MOV	DI,AX
		CLI
		MOV	[DI+PCM_SORC_F],DX
		STI
		RET
;******************************************************************************
;		全体ボリューム設定
;			入力	AL	全体ボリューム(0~15)
;******************************************************************************
PCM_AVOL_SET:
		CMP	AL,16
		JAE	PCM_AVOL_S_09
		MOV	CS:PCM_VOLUME,AL
		;
		CALL	BD_VOL_SET	;ﾎﾞﾘｭｰﾑ設定へ
PCM_AVOL_S_09:
		RET
;******************************************************************************
;		ﾁｬﾈﾙｵｰﾊﾞｰ
;******************************************************************************
CNL_OVER:
		CALL	INT7FH_ERR
		RET
;******************************************************************************
;		コンバート時のボリューム設定
;			入力	DX	ボリューム
;					(0~256~65535)	256 が x1 とする
;******************************************************************************
PCM_CONV_VOL:
		MOV	CS:CONV_VOLUME,DX
		RET
;******************************************************************************
;		PCMテンポラリの指定
;			入力	ES	PCMテンポラリのセグメント
;				DX	PCMテンポラリの大きさ
;******************************************************************************
PCMTMP_SET:
		MOV	CS:PCMTMP_SEG,ES
		MOV	CS:PCMTMP_VOL,DX
		RET
;******************************************************************************
;		常駐解除許可、禁止の指定
;			入力	AL=0	常駐解除許可
;				AL=1	常駐解除禁止
;******************************************************************************
REMOVE_FSET:
		MOV	CS:REMOVE_FLG,AL
		RET
;******************************************************************************
;		ﾁｬﾈﾙ７をADPCMエミュレートフラグ設定
;			入力	AL=0	エミュレートしない
;				AL=1	エミュレートする
;******************************************************************************
ADPCM_EM_SET:
		MOV	CS:ADPCM_EM_FLG,AL
		RET
;******************************************************************************
;		FIFOﾊﾞｯﾌｧの変更
;			IN	DX	FIFOｻｲｽﾞ(80H単位)
;******************************************************************************
FIFOBUFF_SET:
		AND	DX,NOT 80H		;AND (NOT 80H)
		JZ	INT7FH_ERR
		CMP	DX,CS:FIFO_VOLW		;常駐ｻｲｽﾞより大きいとｴﾗｰ
		JA	INT7FH_ERR
		PUSH	DX
		CALL	PCM_ALL_STOP		;PCM全停止
		POP	DX
		MOV	CS:FIFO_VOL,DX
		CALL	FIFO_WK_GET
		RET
;******************************************************************************
;		ステータスの読み込み
;			入力	AL	ファンクション番号
;******************************************************************************
STATUS_GET:
		CMP	AL,STATUS_TBL_MAX
		JAE	STATUS_GET_R
		MOV	BP,CS:PUSH_REG
		XOR	BX,BX
		MOV	BL,AL
		SHL	BX,1
		CALL	CS:[BX+STATUS_TBL]
STATUS_GET_R:
		RET
STATUS_TBL	LABEL	WORD
		DW	DUMMY_COM	;00H
		DW	WORK_ADR_GET	;01H ﾜｰｸｱﾄﾞﾚｽ
		DW	DUMMY_COM	;02H
		DW	DUMMY_COM	;03H
		DW	PCMTMP_SEG_GET	;04H ﾃﾝﾎﾟﾗﾘﾊﾞｯﾌｧｱﾄﾞﾚｽ
		DW	DUMMY_COM	;05H
		DW	ACONV00_GET	;06H ADPCM変換初期化アドレス
		DW	ACONV01_GET	;07H ADPCM変換メインアドレス
		DW	DUMMY_COM	;08H
		DW	B86I_ADR_GET	;09H (PPZ8)割り込みアドレス
		DW	B86_VOL_GET	;0AH (PPZ8)全体ボリューム
		DW	RATENUM_GET	;0BH (PPZ8)再生ﾚｰﾄ番号
		DW	EMS_XMS_GET	;0CH (PPZ8)EMSかXMSか？
		DW	PCME0_ADR_GET	;0DH (PPZ8)PCM0のテーブルアドレス
		DW	PCME1_ADR_GET	;0EH (PPZ8)PCM1のテーブルアドレス
		DW	INT_FLG_ADR	;0FH PCM処理中フラグのアドレス
		DW	INT_NUM_GET	;10H (PPZ8)INT_NUMを得る
		DW	FIFO_VOL_GET	;11H (PPZ8)FIFOﾊﾞｯﾌｧの現在値を得る
		DW	FIFO_MAX_GET	;12H (PPZ8)FIFOﾊﾞｯﾌｧの最大値を得る
		DW	RATE_TBL_GET	;13H (PPZ8)再生ﾚｰﾄﾃｰﾌﾞﾙを得る
STATUS_TBL_MAX	EQU	($-STATUS_TBL)/2
	;=======================================
	;	AL=01H のファンクション
	;　PCM ﾁｬﾈﾙのワークアドレスをえる
	;		ES:BX	アドレス
	;=======================================
WORK_ADR_GET:
		MOV	[BP+_ES],CS
		MOV	[BP+_BX],OFFSET PCM_WORK
		RET
	;=======================================
	;	AL=04H のファンクション
	;　PCMテンポラリのアドレスと大きさを返す
	;		ES	セグメント
	;		BX	大きさ
	;=======================================
PCMTMP_SEG_GET:
		MOV	ES,CS:PCMTMP_SEG
		MOV	BX,CS:PCMTMP_VOL
		MOV	[BP+_ES],ES
		MOV	[BP+_BX],BX
		RET
	;=======================================
	;	AL=06H のファンクション
	;　ADPCM>PCM変換サブルーチンのアドレスを帰す(FAR CALL用)
	;	初期化アドレスを帰す
	;		ES:BX	アドレス
	;=======================================
ACONV00_GET:
		MOV	[BP+_ES],CS
		MOV	[BP+_BX],OFFSET ACONV_00
		RET
	;=======================================
	;	AL=07H のファンクション
	;　ADPCM>PCM変換サブルーチンのアドレスを帰す(FAR CALL用)
	;	変換サブアドレスを帰す
	;		ES:BX	アドレス
	;=======================================
ACONV01_GET:
		MOV	[BP+_ES],CS
		MOV	[BP+_BX],OFFSET ACONV_01
		RET
	;=======================================
	;	AL=09H のファンクション
	;　PPZ8エントリをみる
	;		ES:BX	エントリアドレス
	;=======================================
B86I_ADR_GET:
		MOV	AX,CS:B86I_ADR
;;	MOV	AX,OFFSET DUMMY_FAR
		MOV	[BP+_ES],CS
		MOV	[BP+_BX],AX
		RET
DUMMY_FAR:
	RETF
	;=======================================
	;	AL=0AH のファンクション
	;　全体ボリュームを得る
	;		AL	全体ボリューム
	;=======================================
B86_VOL_GET:
		XOR	AX,AX
		MOV	AL,CS:PCM_VOLUME
		MOV	[BP+_AX],AX
		RET
	;=======================================
	;	AL=0BH のファンクション
	;　再生ﾚｰﾄ番号を得る
	;		AL	再生レート番号
	;=======================================
RATENUM_GET:
		XOR	AX,AX
		MOV	AL,CS:PCM_RATE
		MOV	[BP+_AX],AX
		RET
	;=======================================
	;	AL=0CH のファンクション
	;　EMSかXMSか？
	;		AL	0:EMS使用
	;			1:XMS使用
	;=======================================
EMS_XMS_GET:
		XOR	AX,AX
		MOV	AL,CS:EMS_XMS_FLG
		MOV	[BP+_AX],AX
		RET
	;=======================================
	;	AL=0DH のファンクション
	;　音色ｱﾄﾞﾚｽ0
	;		ES:BX	エントリアドレス
	;=======================================
PCME0_ADR_GET:
		MOV	[BP+_ES],CS
		MOV	[BP+_BX],OFFSET PCME_WORK0
		RET
	;=======================================
	;	AL=0EH のファンクション
	;　音色ｱﾄﾞﾚｽ1
	;		ES:BX	エントリアドレス
	;=======================================
PCME1_ADR_GET:
		MOV	[BP+_ES],CS
		MOV	[BP+_BX],OFFSET PCME_WORK1
		RET
	;=======================================
	;	AL=0FH のファンクション
	;　PCM処理中フラグのアドレス
	;		ES:BX	エントリアドレス
	;=======================================
INT_FLG_ADR:
		MOV	[BP+_ES],CS
		MOV	[BP+_BX],OFFSET INT_FLG
		RET
	;=======================================
	;	AL=10H のファンクション
	;　外部割り込み番号を得る
	;		AX	INT_NUM
	;=======================================
INT_NUM_GET:
		XOR	AX,AX
		MOV	AL,CS:INT_NUM
		MOV	[BP+_AX],AX
		RET
	;=======================================
	;	AL=11H のファンクション
	;　FIFOﾊﾞｯﾌｧの現在値を得る
	;		AX	FIFOｻｲｽﾞ
	;=======================================
FIFO_VOL_GET:
		MOV	AX,CS:FIFO_VOL
		MOV	[BP+_AX],AX
		RET
	;=======================================
	;	AL=12H のファンクション
	;　FIFOﾊﾞｯﾌｧの最大値を得る
	;		AX	FIFOｻｲｽﾞ
	;=======================================
FIFO_MAX_GET:
		MOV	AX,CS:FIFO_VOLW
		MOV	[BP+_AX],AX
		RET
	;=======================================
	;	AL=13H のファンクション
	;　再生ﾚｰﾄﾃｰﾌﾞﾙｱﾄﾞﾚｽを得る
	;		ES:BX	エントリアドレス
	;=======================================
RATE_TBL_GET:
		MOV	AX,OFFSET RATE_TBL_86B
		CMP	CS:BD_FLG,1
		JB	RATETBL_G_01
		MOV	AX,OFFSET RATE_TBL_WSS
		JZ	RATETBL_G_01
		MOV	AX,OFFSET RATE_TBL_SB
RATETBL_G_01:
		MOV	[BX+_ES],CS
		RET
;******************************************************************************
;		FMP チェック
;			出力	ZF=0	常駐していない
;				ZF=1	常駐している
;					ES:BX	前の常駐物のアドレス
;			破壊	AX,BX,CX,DI,SI
;******************************************************************************
FMP_CHECK:
		CLD
		PUSHA
		_PUSH	DS,ES
		MOV	AX,35D2H		;INTD2H の値を得る
		INT	21H
		MOV	SI,OFFSET _FMP		;常駐ﾁｪｯｸ
		MOV	DI,BX
		ADD	DI,2
		MOV	CX,_FMP_L
		REPZ	CMPSB
		JNZ	FMP_SKIP
		MOV	AX,ES:[DI]		;ﾊﾞｰｼﾞｮﾝﾁｪｯｸ
		CMP	AX,FMP1
		JB	FMP_CK_OLD
		MOV	CS:DRIVER_FLG,_FMP_F	;FMPだ
		CLC
		JMP	FMP_SKIP_01
FMP_SKIP:
		STC
FMP_SKIP_01:
		_POP	DS,ES
		POPA
		RET
FMP_CK_OLD:
		JMP	FMP_SKIP
FMP_CK_NEW:
;******************************************************************************
;		PMDﾁｪｯｸ
;******************************************************************************
PMD_CHECK:
		CLD
		_PUSH	DS,ES
		MOV	AX,CS
		MOV	DS,AX
		MOV	AX,3560H
		INT	21H
		MOV	SI,OFFSET _PMD
		MOV	DI,BX
		ADD	DI,2
		MOV	CX,_PMD_L
		REPZ	CMPSB
		JNZ	PMD_CK_09
		MOV	CS:DRIVER_FLG,_PMD_F
		CLC
		_POP	DS,ES
		RET
PMD_CK_09:
		STC
		_POP	DS,ES
		RET
_PMD		DB	'PMD'
_PMD_L		EQU	$-_PMD
;******************************************************************************
;		MDZﾁｪｯｸ
;******************************************************************************
MDZ_CHECK:
		CLD
		_PUSH	DS,ES
		MOV	AX,CS
		MOV	DS,AX
		MOV	AX,35D2H
		INT	21H
		MOV	SI,OFFSET _MDZ
		MOV	DI,BX
		ADD	DI,2
		MOV	CX,_MDZ_L
		REPZ	CMPSB
		JNZ	MDZ_CK_09
		MOV	CS:DRIVER_FLG,_MDZ_F
		;
		MOV	AX,0D0EH		;ﾄﾞﾗｲﾊﾞｰINT番号
		INT	0D2H
		MOV	CS:DRIVER_INT_NUM,AL
		;
		CLC
		_POP	DS,ES
		RET
MDZ_CK_09:
		STC
		_POP	DS,ES
		RET
_MDZ		DB	'MDZ'
_MDZ_L		EQU	$-_MDZ
;******************************************************************************
;		停止
;******************************************************************************
DRIVER_STOP:
		CALL	FMP_CHECK
		JNC	FMP_STOP
		CALL	MDZ_CHECK
		JNC	MDZ_STOP
		CALL	PMD_CHECK
		JNC	PMD_STOP
		RET
	;=======================================
	;	FMP停止
	;FMP側がPPZを使用中かみる
	;AL=04,  AH=12... 内部状態BIT取得     AX=ビットデータ
	;=======================================
FMP_STOP:
		PUSH	AX
		MOV	AX,1204H
		INT	0D2H
		TEST	AX,0002H
		JZ	FMP_STOP_01
		;
		XOR	AX,AX			;演奏終了
		INT	0D2H
FMP_STOP_01:
		POP	AX
FMP_STOP_02:
		RET
	;=======================================
	;	MDZ停止
	;=======================================
MDZ_STOP:
		PUSH	AX
		MOV	AH,01H
		INT	0D2H
		POP	AX
		RET
	;=======================================
	;	PMD停止
	;=======================================
PMD_STOP:
		PUSH	AX
		MOV	AH,01H
		INT	60H
		POP	AX
		RET
;******************************************************************************
;		環境変数を得る
;			IN	DX	環境変数名
;			OUT	DS:SI	環境変数の内容
;				AL	環境変数の有無	0:ある	-1:ない
;******************************************************************************
KAN_GET:
		MOV	AH,62H		;カレントのセグメントを得る
		INT	21H
		MOV	DS,BX
		MOV	DS,DS:[2CH]
		MOV	AX,CS
		MOV	ES,AX
		;
		XOR	SI,SI
KAN_GET_01:
		CMP	BYTE PTR [SI],0
		JZ	KAN_ERR
KAN_GET_02:
		MOV	DI,DX
KAN_GET_021:
		CMP	BYTE PTR ES:[DI],0
		JZ	KAN_GET_03
		LODSB
		CMP	AL,ES:[DI]
		JNZ	KAN_GET_05
		INC	DI
		JMP	KAN_GET_021
KAN_GET_03:
		LODSB
		CMP	AL,' '
		JZ	KAN_GET_03
		CMP	AL,'='
		JNZ	KAN_GET_05
KAN_GET_04:
		LODSB
		CMP	AL,' '
		JZ	KAN_GET_04
		DEC	SI
		CMP	BYTE PTR [SI],0
		JZ	KAN_ERR
		XOR	AL,AL			;環境変数がある
		RET
KAN_GET_05:
		LODSB
		CMP	AL,0
		JNZ	KAN_GET_05
		JMP	KAN_GET_01
KAN_ERR:
		MOV	AX,CS
		MOV	DS,AX
		MOV	AL,-1			;環境変数がない
		RET
	;=======================================
	;	0 がくるまで転送する
	;=======================================
FILE_SENT:
		LODSB
		OR	AL,AL
		JZ	FILE_SENT_SKIP
		STOSB
		JMP	FILE_SENT
FILE_SENT_SKIP:
		RET
FILE_SENT2:
		LODSB
		OR	AL,AL
		JZ	FILE_SENT_SKIP
		CMP	AL,'.'
		JZ	FILE_SENT_SKIP
		STOSB
		JMP	FILE_SENT2
FILE_SENT3:
		LDS	SI,CS:FILE_SENT_ADR
FILE_SENT3_01:
		LODSB
		CMP	AL,';'
		JZ	FILE_SENT3_03
		OR	AL,AL
		JZ	FILE_SENT3_02
		STOSB
		JMP	FILE_SENT3_01
FILE_SENT3_02:
		MOV	CS:FILE_SENT_FLG,0
		RET
FILE_SENT3_03:
		MOV	CS:FILE_SENT_FLG,1
		MOV	CS:FILE_SENT_OFF,SI
		MOV	CS:FILE_SENT_SEG,DS
		;
		RET
;******************************************************************************
;		PVIファイルオープン
;			入力	DS:DX	ファイル名
;			出力	CY=0	正常終了
;				HANDLE	ファイルハンドル
;				CY=1	異常終了
;******************************************************************************
PVI_FILE_OPEN:
		MOV	CS:FILE_SENT_FLG,0
		MOV	CS:PVI_FILE_OFF,DX
		MOV	CS:PVI_FILE_SEG,DS
		;
		CMP	CS:NOW_PCM_NUM,0
		JNZ	PVI_OPEN_00
		MOV	CS:PVI_FILE_WADR,OFFSET PVI_FILE_WK0
		MOV	CS:PCM0_USE_WK,0
		JMP	PVI_OPEN_01
PVI_OPEN_00:
		MOV	CS:PVI_FILE_WADR,OFFSET PVI_FILE_WK1
		MOV	CS:PCM1_USE_WK,0
PVI_OPEN_01:
		MOV	AX,CS
		MOV	DS,AX
		MOV	AH,2FH		;DTA設定
		INT	21H
		MOV	OLD_DTA_OFF,BX
		MOV	OLD_DTA_SEG,ES
		MOV	DX,OFFSET DTA
		MOV	AH,1AH
		INT	21H
		MOV	AX,CS
		MOV	ES,AX
		;
		CMP	CS:KAN_LOOK_FLG,0	;環境変数をみるか？
		JNZ	PVI_FILE_OPEN2
		;
		CLD
		MOV	DX,OFFSET __PVI	;環境変数名
		CALL	KAN_GET
		MOV	DI,CS		;ES:DI = PVI_FILE_WK
		MOV	ES,DI
		MOV	DI,CS:PVI_FILE_WADR
		OR	AL,AL		;環境変数がなかったら
		JS	PVI_OPEN_03
		MOV	CS:FILE_SENT_OFF,SI
		MOV	CS:FILE_SENT_SEG,DS
PVI_OPEN_02:
		CALL	FILE_SENT3
		MOV	AL,'\'		;\
		STOSB
PVI_OPEN_03:
		MOV	AX,CS
		MOV	DS,AX
		MOV	PVI_FILE_ADR,DI
		LDS	SI,PVI_FILE_TOP
		CALL	FILE_SENT2
		MOV	AX,CS
		MOV	DS,AX
		MOV	SI,OFFSET _PVI	;.PVI (ADPCM)
		CMP	NOW_PCM_CATE,0
		JZ	PVI_OPEN_04
		MOV	SI,OFFSET _PZI	;.PZI (PCM)
PVI_OPEN_04:
		CALL	FILE_SENT
		MOV	PVI_FILE_END,DI
		XOR	AL,AL		;0
		STOSB
		;
		MOV	DX,PVI_FILE_ADR		;環境変数を見ないで
		MOV	PVI_FILE_NAME,DX
		XOR	CX,CX			;普通のファイル
		MOV	AH,4EH			;ファイルの検索
		INT	21H
		JNC	PVI_OPEN_10
		;
		MOV	DX,PVI_FILE_WADR	;環境変数を参照
		MOV	PVI_FILE_NAME,DX
		XOR	CX,CX			;普通のファイル
		MOV	AH,4EH			;ファイルの検索
		INT	21H
		JNC	PVI_OPEN_10
		;
		CMP	FILE_SENT_FLG,0
		JZ	PVI_OPEN_ERR0
		;
		MOV	DI,CS		;ES:DI = PVI_FILE_WK
		MOV	ES,DI
		MOV	DI,PVI_FILE_WADR
		;
		JMP	PVI_OPEN_02
	;=======================================
	;	ファイルの大きさチェック
	;=======================================
PVI_OPEN_10:
		MOV	AX,CS
		MOV	DS,AX
		MOV	ES,AX
		;
		MOV	AX,WORD PTR DTA+1AH	;ファイルの大きさを得る
		MOV	PVI_FILE_VOL+0,AX
		MOV	AX,WORD PTR DTA+1CH
		MOV	PVI_FILE_VOL+2,AX
		;
		MOV	DX,PVI_FILE_VOL+2	;DX:CX = ファイルの大きさ
		MOV	CX,PVI_FILE_VOL+0
		MOV	BX,14-1			;EMS 16Kbyte
		MOV	AX,(4000H/2)-1
		CMP	EMS_XMS_FLG,0
		JZ	PVI_OPEN_11
		MOV	BX,10-1			;XMS 1Kbyte
		MOV	AX,(0400H/2)-1
PVI_OPEN_11:
		MOV	SI,PVI_DATA_TOP		;ADPCMの場合 x2
		CMP	NOW_PCM_CATE,0
		JZ	PVI_OPEN_12
		MOV	SI,PZI_DATA_TOP		;PCMの場合 x1
		INC	BX
		SHL	AX,1
		INC	AX
PVI_OPEN_12:
		SUB	CX,SI			;DX:CX - ヘッダー分
		SBB	DX,0
		ADD	CX,AX			;下位をそろえる
		ADC	DX,0
PVI_OPEN_13:
		SHR	DX,1			;データを割る
		RCR	CX,1
		DEC	BX
		JNZ	PVI_OPEN_13
		;
		CMP	EMS_XMS_FLG,0
		JNZ	PVI_OPEN_14
		MOV	AL,NOW_PCM_NUM		;現在のPCM番号
		CALL	EMS_REALLOC		;EMS確保
		JC	PVI_OPEN_19
		JMP	PVI_VOL_OK
PVI_OPEN_14:
		_PUSH	CX,DX,ES
		MOV	AX,CS
		MOV	ES,AX
		MOV	AL,NOW_PCM_NUM		;現在のPCM番号
		CALL	XMS_DEALLOC		;XMS開放
		_POP	CX,DX,ES
		JC	PVI_OPEN_19
		MOV	AL,NOW_PCM_NUM		;現在のPCM番号
		CALL	XMS_ALLOC		;XMS確保
		JC	PVI_OPEN_19
		JMP	PVI_VOL_OK
PVI_OPEN_19:
		MOV	AX,CS
		MOV	DS,AX
		JMP	PVI_OPEN_ERR2
PVI_VOL_OK:
		MOV	DX,PVI_FILE_NAME
		MOV	AX,3D00H
		INT	21H
		JC	PVI_OPEN_ERR0
		MOV	HANDLE,AX
		;
		CALL	PVI_OPEN_20		;DTAを戻す
		;
		CLC
		RET
PVI_OPEN_ERR0:
		CALL	PVI_OPEN_20		;DTAを戻す
		;
		XOR	AX,AX
		STC
		RET
PVI_OPEN_ERR2:
		CALL	PVI_OPEN_20		;DTAを戻す
		;
		MOV	AX,2
		STC
		RET
	;=======================================
	;	DTAを戻す
	;=======================================
PVI_OPEN_20:
		LDS	DX,CS:OLD_DTA_ADR
		MOV	AH,1AH
		INT	21H
		MOV	AX,CS
		MOV	DS,AX
		RET
	;=======================================
	;	環境変数をみない
	;=======================================
PVI_FILE_OPEN2:
		CLD
		MOV	AX,CS
		MOV	ES,AX
		MOV	DI,CS:PVI_FILE_WADR
		LDS	SI,CS:PVI_FILE_TOP
PVI_OPEN2_01:
		MOVSB
		CMP	BYTE PTR DS:[SI-1],0
		JNZ	PVI_OPEN2_01
		MOV	AX,CS
		MOV	DS,AX
		;
		MOV	DX,PVI_FILE_WADR	;環境変数を参照
		MOV	PVI_FILE_NAME,DX
		XOR	CX,CX			;普通のファイル
		MOV	AH,4EH			;ファイルの検索
		INT	21H
		JNC	PVI_OPEN_10
		;
		JMP	PVI_OPEN_ERR0
;******************************************************************************
;		PVIファイルのクローズ
;			入力	HANDLE	ファイルハンドル
;			出力	CY=0	正常終了
;				CY=1	異常終了
;******************************************************************************
PVI_FILE_CLOSE:
		MOV	BX,CS:HANDLE
		MOV	AH,3EH			;読み込みファイルのクローズ
		INT	21H
		JC	PVI_CLOSE_ERR
		;
		CLC
		RET
PVI_CLOSE_ERR:
		STC
		RET
;******************************************************************************
;		PVI&PZIファイルの読み込み
;			入力	DS:DX	ファイル名
;				AL	0:環境変数をみてオープン
;					1:環境変数をみないでオープン
;				CL	0:PCMバッファ0
;					1:PCMバッファ1
;				CH	0:.PVI (ADPCM)
;					1:.PZI (PCM)
;			出力	CY=0	正常終了
;				CY=1	異常終了
;				AX	エラー番号
;				AX=0	読み込み失敗
;				AX=1	データ形式が違う
;				AX=2	メモリが確保できない
;				AX=3	EMSハンドルのマッピングができない
;******************************************************************************
PVI_LOAD_COM:
		CLI
		_PUSH	DX,DS
		MOV	CS:KAN_LOOK_FLG,AL	;環境変数を参照するか？
		MOV	CS:NOW_PCM_NUM,CL	;読み込むPCMバッファ番号
		MOV	CS:NOW_PCM_CATE,CH	;PCM形式
		;
		MOV	DX,OFFSET PCME_WORK0	;どちらのヘッダーか？
		CMP	CS:NOW_PCM_NUM,0
		JZ	PVI_LOAD_01
		MOV	DX,OFFSET PCME_WORK1
PVI_LOAD_01:
		MOV	CS:PCME_ADR,DX
		CALL	WORK_INIT		;ワーク初期化
		;
		CALL	BD_PCM_STOP		;PCM停止
		;
		CMP	CS:EMS_XMS_FLG,0
		JNZ	PVI_LOAD_02
		;EMSのハンドルセーブ
		MOV	DX,CS:EMS_HANDLE0	;EMSハンドル0のセーブ
		MOV	AH,47H
		INT	67H
		MOV	DX,CS:EMS_HANDLE1	;EMSハンドル1のセーブ
		MOV	AH,47H
		INT	67H
PVI_LOAD_02:
		_POP	DX,DS
		STI
	;=======================================
	;	PVI&PZIのオープン
	;=======================================
		CALL	PVI_FILE_OPEN	;PVIファイルのオープン
		JC	PVI_LOAD_ERR
	;=======================================
	;	PVI&PZIのヘッダー部分読み込み
	;=======================================
		MOV	AX,CS		;DS=CS
		MOV	DS,AX
		;
		MOV	CX,PVI_DATA_TOP	;PVI (ADPCM)
		CMP	NOW_PCM_CATE,0
		JZ	PVI_LOAD_03
		MOV	CX,PZI_DATA_TOP	;PZI (PCM)
PVI_LOAD_03:
		MOV	BX,HANDLE	;PVIのヘッダー部分の読み込み
		MOV	DX,PCME_ADR
		MOV	AH,3FH
		INT	21H
		JC	PVI_LOAD_ERR0
	;=======================================
	;	認識文字列'PVI'&'PZI'のチェック
	;=======================================
		MOV	BX,PCME_ADR
		CMP	NOW_PCM_CATE,0
		JNZ	PVI_LOAD_05
		;.PVI (ADPCM)
		CMP	BYTE PTR [BX+0],'P'
		JNZ	PVI_LOAD_ERR1
		CMP	BYTE PTR [BX+1],'V'
		JNZ	PVI_LOAD_ERR1
		CMP	BYTE PTR [BX+2],'I'
		JNZ	PVI_LOAD_ERR1
		;MOV	AL,BYTE PTR [BX+3]	;バージョンを得る
		;MOV	PVI_VER,AL
		;
		MOV	CX,128			;PZI<=PVIヘッダーに変換
		LEA	SI,[BX+PVI_DATA_TOP-04H]
		LEA	DI,[BX+PZI_DATA_TOP-12H]
PVI_LOAD_04:
		XOR	DX,DX			;DX:AXに先頭アドレス
		MOV	AX,[SI+0]
		REPT	5+1			;32byte*2
		SHL	AX,1
		RCL	DX,1
		ENDM
		XOR	BP,BP			;BP:BXにデータ量
		MOV	BX,[SI+2]
		SUB	BX,[SI+0]
		INC	BX
		REPT	5+1			;32byte*2
		SHL	BX,1
		RCL	BP,1
		ENDM
		MOV	DS:[DI+0],AX
		MOV	DS:[DI+2],DX
		MOV	DS:[DI+4],BX
		MOV	DS:[DI+6],BP
		MOV	AX,-1			;ループしない
		MOV	[DI+08],AX
		MOV	[DI+10],AX
		MOV	[DI+12],AX
		MOV	[DI+14],AX
		MOV	WORD PTR [DI+16],16000	;16KHzデフォルト
		SUB	SI,04H
		SUB	DI,12H
		LOOP	PVI_LOAD_04
		;
		JMP	PVI_LOAD_06
		;.PZI (PCM)
PVI_LOAD_05:
		CMP	BYTE PTR [BX+0],'P'
		JNZ	PVI_LOAD_ERR1
		CMP	BYTE PTR [BX+1],'Z'
		JNZ	PVI_LOAD_ERR1
		CMP	BYTE PTR [BX+2],'I'
		JNZ	PVI_LOAD_ERR1
		;MOV	AL,BYTE PTR [BX+3]	;バージョンを得る
		;MOV	PZI_VER,AL
PVI_LOAD_06:
	;=======================================
	;	データ読み込み＆コンバート
	;=======================================
		CMP	NOW_PCM_CATE,0		;ADPCMかPCMか？
		JNZ	PVI_LOAD_20
	;=======================================
	;	.PVI(ADPCM)データの場合
	;=======================================
		MOV	AX,CS
		MOV	DS,AX
		CALL	PVITMP_LOAD		;テンポラリにデータ読み込み
		JC	PVI_LOAD_ERR0
		MOV	CS:NOW_CONV_PVI,0	;現在コンバート中のPVI=0
		;
		CMP	CS:EMS_XMS_FLG,0
		JNZ	PVI_LOAD_11
		;EMSの場合初期化
		MOV	ES,CS:EMS_FRAME_SEG	;書き込みセグメントの先頭
		XOR	DI,DI
		MOV	CS:EMS_NOW_PAGE,0	;EMSの現在のページ
		JMP	PVI_LOAD_12
PVI_LOAD_11:
		;XMSの場合初期化
		.386P
		_XMS	05H			;ローカルなA20の有効
		;
		XOR	AX,AX			;ES:EDI プロテクトアドレス
		MOV	ES,AX
		MOV	EDI,CS:XMS_FRAME_ADR0
		CMP	CS:NOW_PCM_NUM,0
		JZ	PVI_LOAD_12
		MOV	EDI,CS:XMS_FRAME_ADR1
		.186
PVI_LOAD_12:
		CALL	ONE_PVI_INIT	;１つのPVIの初期化
PVI_LOAD_13:
		CMP	CS:EMS_XMS_FLG,0
		JNZ	PVI_LOAD_14
		;EMSの場合
		OR	DI,DI
		JNZ	PVI_LOAD_131
		CALL	EMS_HANDLE_MAP		;EMSのマップ
		JC	PVI_LOAD_ERR3
PVI_LOAD_131:
		MOV	AL,[SI]		;上位4bitの変換
		SHR	AL,4
		CALL	PCM_CONV	;ADPCM>PCMへ変換
		STOSB
		LODSB			;下位4bitの変換
		CALL	PCM_CONV	;ADPCM>PCMへ変換
		STOSB
		CMP	DI,4000H	;16kbyteを越えたら
		JNZ	PVI_LOAD_15
		;
		INC	CS:EMS_NOW_PAGE		;ページ+1
		XOR	DI,DI			;OFFSET = 0
		JMP	PVI_LOAD_15
PVI_LOAD_14:
		;XMSの場合
		.386P
		CALL	SET_REAL4G
		;
		MOV	AL,[SI]		;上位4bitの変換
		SHR	AL,4
		CALL	PCM_CONV	;ADPCM>PCMへ変換
		DB	67H		;ES:[EDI]<=AL:INC EDI
		STOSB
		LODSB			;下位4bitの変換
		CALL	PCM_CONV	;ADPCM>PCMへ変換
		DB	67H		;ES:[EDI]<=AL:INC EDI
		STOSB
		;
		STI
		.186
PVI_LOAD_15:
		CMP	SI,CS:PCMTMP_VOL	;テンポラリの大きさを越えたら
		JB	PVI_LOAD_16
		CALL	PVITMP_LOAD		;データ読み込み
		JC	PVI_LOAD_ERR0
PVI_LOAD_16:
		LOOP	PVI_LOAD_13	;DEC BP:CX カウンタ-1
		DEC	BP
		JNZ	PVI_LOAD_13
		;
		;ALにPVIの設定数を得る
		MOV	BP,CS:PCME_ADR
		MOV	AL,CS:[BP+PVI_NUM_MAX]
		CMP	AL,CS:NOW_CONV_PVI	;データ数が越えたら終了
		JNZ	PVI_LOAD_12
		;
		CMP	CS:EMS_XMS_FLG,0
		JZ	PVI_LOAD_17
		;XMSの場合
		_XMS	06H			;ローカルなA20の無効
PVI_LOAD_17:
		JMP	PVI_LOAD_99
	;=======================================
	;	.PZI(PCM)データの場合
	;=======================================
PVI_LOAD_20:
		CMP	CS:EMS_XMS_FLG,0
		JNZ	PVI_LOAD_30
		;EMSの場合
		MOV	CS:EMS_NOW_PAGE,0	;EMSの現在のページ
		;
		MOV	CX,CS:EMS_KEEP_PAGE0
		CMP	CS:NOW_PCM_NUM,0
		JZ	PVI_LOAD_21
		MOV	CX,CS:EMS_KEEP_PAGE1
PVI_LOAD_21:
		PUSH	CX
		CALL	EMS_HANDLE_MAP		;EMSのマップ
		POP	CX
		JC	PVI_LOAD_ERR3
		_PUSH	CX,DS
		MOV	BX,CS:HANDLE
		MOV	CX,4000H		;16Kbyte
		XOR	DX,DX
		MOV	DS,CS:EMS_FRAME_SEG	;テンポラリのセグメント
		MOV	AH,3FH
		INT	21H
		_POP	CX,DS
		JC	PVI_LOAD_ERR0
		INC	CS:EMS_NOW_PAGE		;EMSの現在のページ+1
		LOOP	PVI_LOAD_21
		;
		JMP	PVI_LOAD_99
PVI_LOAD_30:
		;XMSの場合
		.386P
		_XMS	05H			;ローカルなA20の有効
		;
		XOR	AX,AX			;ES:EDI プロテクトアドレス
		MOV	ES,AX
		MOV	EDI,XMS_FRAME_ADR0
		CMP	CS:NOW_PCM_NUM,0
		JZ	PVI_LOAD_31
		MOV	EDI,XMS_FRAME_ADR1
PVI_LOAD_31:
		PUSH	EDI
		_PUSH	DS,ES
		MOV	BX,CS:HANDLE
		MOV	CX,CS:PCMTMP_VOL	;テンポラリの量だけ読む
		XOR	DX,DX
		MOV	DS,CS:PCMTMP_SEG	;テンポラリのセグメント
		MOV	AH,3FH
		INT	21H
		_POP	DS,ES
		POP	EDI
		JC	PVI_LOAD_ERR0
		OR	AX,AX
		JZ	PVI_LOAD_35		;読み込み終了
		;
		CALL	SET_REAL4G
		;
		MOV	DS,CS:PCMTMP_SEG	;DS:SI データの先頭
		XOR	ESI,ESI
		AND	ECX,0FFFFH
		SHR	ECX,1
		JNC	PVI_LOAD_32
		DB	67H
		MOVSB
PVI_LOAD_32:
		SHR	ECX,1
		JNC	PVI_LOAD_33
		DB	67H
		MOVSW
PVI_LOAD_33:
		JZ	PVI_LOAD_34
		DB	67H
		REP	MOVSD
PVI_LOAD_34:
		STI
		;
		JMP	PVI_LOAD_31
PVI_LOAD_35:
		;XMSの場合
		_XMS	06H			;ローカルなA20の無効
		;
		JMP	PVI_LOAD_99
		.186
	;=======================================
	;	PVIファイルクローズ
	;=======================================
PVI_LOAD_99:
		MOV	AX,CS
		MOV	DS,AX
		MOV	ES,AX
		CALL	PVI_FILE_CLOSE		;ファイルのクローズ
		;
		CMP	CS:EMS_XMS_FLG,0
		JNZ	PVI_LOAD_991
		;EMSのハンドルリストア
		MOV	DX,EMS_HANDLE0		;EMSハンドル0リストア
		MOV	AH,48H
		INT	67H
		MOV	DX,EMS_HANDLE1		;EMSハンドル1リストア
		MOV	AH,48H
		INT	67H
PVI_LOAD_991:
		RET
;******************************************************************************
;	変換時の変数の初期化とデータ量の算出
;				IN	BP:CX	変換するデータ量
;******************************************************************************
ONE_PVI_INIT:
		PUSH	ES
		;
		CALL	PCM_CONV_INIT		;予測値とDELTA_Nの初期化
		;
		XOR	BX,BX			;BX 現在変換するPVIテーブル
		MOV	BL,CS:NOW_CONV_PVI	;BX=BX*12H+PZI_TBL_TOP
		MOV	BP,BX
		SHL	BP,1
		SHL	BX,4
		ADD	BX,BP
		ADD	BX,PZI_TBL_TOP
		ADD	BX,CS:PCME_ADR
		;
		;BP:CXにデータ量
		MOV	CX,CS:[BX+4]
		MOV	BP,CS:[BX+6]
		SHR	BP,1			;PCMのデータ量としてあるので
		RCR	CX,1			;変換回数は/2
		INC	BP			;DEC のため BP+1
		;
		INC	CS:NOW_CONV_PVI		;PVIの番号を+1
		;
		POP	ES
		RET
	;=======================================
	;	データの読み込み
	;	元データアドレスの初期化
	;		DS:SI	ADPCMデータ
	;=======================================
PVITMP_LOAD:
		;テンポラリにデータ読み込み
		PUSHA
		_PUSH	DS,ES
		MOV	BX,CS:HANDLE
		MOV	CX,CS:PCMTMP_VOL	;テンポラリの量だけ読む
		XOR	DX,DX
		MOV	DS,CS:PCMTMP_SEG	;テンポラリのセグメント
		MOV	AH,3FH
		INT	21H
		_POP	DS,ES
		POPA
		JC	PVITMP_LOAD_ERR
		;
		MOV	DS,CS:PCMTMP_SEG	;DS:SI データの先頭
		XOR	SI,SI
		;
		CLC
		RET
PVITMP_LOAD_ERR:
		STC
		RET
	;=======================================
	;	ハンドルのマッピング
	;=======================================
EMS_HANDLE_MAP:
		PUSHA
		_PUSH	DS,ES
		MOV	DX,CS:EMS_HANDLE0
		CMP	CS:NOW_PCM_NUM,0
		JZ	EMS_H_MAP_01
		MOV	DX,CS:EMS_HANDLE1
EMS_H_MAP_01:
		MOV	BX,CS:EMS_NOW_PAGE
		XOR	AL,AL
		MOV	AH,44H
		INT	67H
		OR	AH,AH
		_POP	DS,ES
		POPA
		JNZ	EMS_H_MAP_09
		CLC
		RET
EMS_H_MAP_09:
		STC
		RET
;******************************************************************************
;		読み込みエラー
;				00H	ファイルの読み込み失敗
;				01H	データ形式が違う
;				02H	メモリが確保できない
;				03H	EMSハンドルのマッピングができない
;******************************************************************************
PVI_LOAD_ERR0:
		XOR	AX,AX
		JMP	PVI_LOAD_ERR
PVI_LOAD_ERR1:
		MOV	AX,1
		JMP	PVI_LOAD_ERR
PVI_LOAD_ERR2:
		MOV	AX,2
		JMP	PVI_LOAD_ERR
PVI_LOAD_ERR3:
		MOV	AX,3
		JMP	PVI_LOAD_ERR
PVI_LOAD_ERR:
		MOV	BP,CS:PUSH_REG
		MOV	[BP+_AX],AX
		CALL	INT7FH_ERR
		JMP	PVI_LOAD_99
;******************************************************************************
;		EMSメモリの再アロケート
;				IN	CX	データ量(16Kbyte単位)
;					AL	PCM番号
;******************************************************************************
EMS_REALLOC:
		MOV	BX,CX			;BXに獲得ページ数
		;
		OR	AL,AL
		JNZ	EMS_AL_01
		;
		MOV	EMS_KEEP_PAGE0,BX
		MOV	DX,EMS_HANDLE0
		MOV	AH,51H			;ページの再アロケート
		INT	67H
		OR	AH,AH
		JNZ	EMS_AL_09
		MOV	PCM0_USE,1
		MOV	PCM0_USE_WK,1
		;
		CLC
		RET
EMS_AL_01:
		MOV	EMS_KEEP_PAGE1,BX
		MOV	DX,EMS_HANDLE1
		MOV	AH,51H			;ページの再アロケート
		INT	67H
		OR	AH,AH
		JNZ	EMS_AL_09
		MOV	PCM1_USE,1
		MOV	PCM1_USE_WK,1
		;
		CLC
		RET
EMS_AL_09:
		STC
		RET
;******************************************************************************
;		XMSメモリの確保
;				IN	CX	データ量(1Kbyte単位)
;					AL	PCM番号
;******************************************************************************
XMS_ALLOC:
		MOV	DX,CX			;DXに獲得Kbyte数
		;
		OR	AL,AL
		JNZ	XMS_AL_01
		;
		MOV	XMS_KEEP_VOL0,DX
		MOV	PCM0_USE,0		;PCM0フラグクリア
		_XMS	09H			;メモリブロックの確保
		OR	AX,AX
		JZ	XMS_AL_09
		MOV	XMS_HANDLE0,DX
		_XMS	0CH			;メモリブロックのロック
		OR	AX,AX
		JZ	XMS_AL_09
		MOV	WORD PTR XMS_FRAME_ADR0+0,BX
		MOV	WORD PTR XMS_FRAME_ADR0+2,DX
		MOV	PCM0_USE,1		;PCM0使用中
		MOV	PCM0_USE_WK,1		;PCM0使用中
		;
		CLC
		RET
XMS_AL_01:
		MOV	XMS_KEEP_VOL1,DX
		MOV	PCM1_USE,0		;PCM1フラグクリア
		_XMS	09H			;メモリブロックの確保
		OR	AX,AX
		JZ	XMS_AL_09
		MOV	XMS_HANDLE1,DX
		_XMS	0CH			;メモリブロックのロック
		OR	AX,AX
		JZ	XMS_AL_09
		MOV	WORD PTR XMS_FRAME_ADR1+0,BX
		MOV	WORD PTR XMS_FRAME_ADR1+2,DX
		MOV	PCM1_USE,1		;PCM1使用中
		MOV	PCM1_USE_WK,1		;PCM1使用中
		;
		CLC
		RET
XMS_AL_09:
		STC
		RET
;******************************************************************************
;		XMSメモリの開放
;				IN	ES	セグメント
;					AL	PCM番号
;******************************************************************************
XMS_DEALLOC:
		OR	AL,AL
		JNZ	XMS_DE_02
		;
		CMP	ES:PCM0_USE,0		;PCM0を使っているか？
		JZ	XMS_DE_01
		MOV	DX,ES:XMS_HANDLE0
		_XMS	0DH			;メモリブロックのアンロック
		MOV	DX,ES:XMS_HANDLE0
		_XMS	0AH			;メモリブロックの開放
XMS_DE_01:
		CLC
		RET
XMS_DE_02:
		CMP	ES:PCM1_USE,0		;PCM1を使っているか？
		JZ	XMS_DE_03
		MOV	DX,ES:XMS_HANDLE1
		_XMS	0DH			;メモリブロックのアンロック
		MOV	DX,ES:XMS_HANDLE1
		_XMS	0AH			;メモリブロックの開放
XMS_DE_03:
		CLC
		RET
XMS_DE_09:
		STC
		RET
;******************************************************************************
;		EMSのチェック
;******************************************************************************
EMS_CHECK:
		PUSHA
		_PUSH	DS,ES
		MOV	EMS_FLG,0
		MOV	AX,3567H		;INT67Hのチェック
		INT	21H
		MOV	DI,000AH		;'EMMXXXX0'のチェック
		MOV	SI,OFFSET EMS_MOJI
		MOV	CX,8
		CLD
		REPZ	CMPSB
		JNZ	EMS_CK_01
		;
		MOV	AH,41H			;ページフレームアドレスの獲得
		INT	67H
		OR	AH,AH
		JNZ	EMS_CK_01
		MOV	EMS_FRAME_SEG,BX
		;
		MOV	EMS_FLG,1
EMS_CK_01:
		_POP	DS,ES
		POPA
		RET
;******************************************************************************
;		XMSのチェック
;******************************************************************************
XMS_CHECK:
		PUSHA
		_PUSH	DS,ES
		MOV	XMS_FLG,0
		MOV	AX,4300H
		INT	2FH
		CMP	AL,80H
		JNZ	XMS_CK_01
		;
		MOV	AX,4310H
		INT	2FH
		MOV	XMS_OFF,BX
		MOV	XMS_SEG,ES
		MOV	XMS_FLG,1
XMS_CK_01:
		_POP	DS,ES
		POPA
		RET
;******************************************************************************
;		GDT計算
;******************************************************************************
		.386P
GDT_CALC:
		XOR	EAX,EAX			;設定するGDTのリニアアドレス
		MOV	AX,DS			;を求める
		SHL	EAX,4
		XOR	EBX,EBX
		LEA	BX,CS:desc_base
		ADD	EAX,EBX
		MOV	CS:gdt_ptr_base,EAX
		;
		RET
;******************************************************************************
;		リアルモードで４Ｇｂｙｔｅアクセスできるように
;		GDTを設定する
;******************************************************************************
SET_REAL4G:
		PUSH	EAX
		PUSH	DS
		CLI
		MOV	AX,CS
		MOV	DS,AX
		SGDT	OLD_GDT_PTR		;GDTの値が同じかチェック
		MOV	AX,WORD PTR OLD_GDT_PTR+0
		CMP	AX,WORD PTR GDT_PTR+0
		JNZ	SET_REAL4G_01
		MOV	EAX,DWORD PTR OLD_GDT_PTR+2
		CMP	EAX,DWORD PTR GDT_PTR+2
		JNZ	SET_REAL4G_01
		POP	DS
		POP	EAX
		RET
SET_REAL4G_01:
		POP	DS
		POP	EAX
		;
		PUSHAD
		PUSH	DS
		PUSH	ES
		PUSH	FS
		PUSH	GS
		;
		MOV	BX,SS
		DB	66H			;GDT設定
		LGDT	CS:GDT_PTR
		MOV	EAX,CR0			;プロテクト移行
		OR	AL,1
		MOV	CR0,EAX
		JMP	$+2			;キャシュフラッシュ
		;
		MOV	AX,SEG_FLAT		;4Gbyteセグメント設定
		MOV	DS,AX
		MOV	ES,AX
		MOV	FS,AX
		MOV	GS,AX
		MOV	SS,AX
		MOV	SP,SP
		MOV	EAX,CR0			;リアル復帰
		AND	AL,0FEH
		MOV	CR0,EAX
		JMP	$+2			;キャシュフラッシュ
		MOV	SS,BX
		MOV	SP,SP
		POP	GS
		POP	FS
		POP	ES
		POP	DS
		POPAD
		;
		OUT	0F2H,AL			;A20 OK
		RET
		.186
;******************************************************************************
;		ADPCM>PCMの変換ルーチンFAR CALL 呼びだし用
;******************************************************************************
ACONV_00:
		CALL	PCM_CONV_INIT
		RETF
ACONV_01:
		CALL	PCM_CONV
		RETF
;******************************************************************************
;		ADPCM>PCMコンバート時の初期化
;		予測値とDELTA_Nの初期化
;******************************************************************************
PCM_CONV_INIT:
		MOV	CS:X_N,X_N0*256		;予測値の初期化
		MOV	CS:DELTA_N,DELTA_N0	;DELTA_Nの初期化
		RET
;******************************************************************************
;		ADPCM>PCMのコンバート
;******************************************************************************
PCM_CONV_SUB:
		CALL	PCM_CONV
		MOV	BP,CS:PUSH_REG
		XOR	AH,AH
		MOV	[BP+_AX],AX
		RET
;******************************************************************************
;		予測値と量子化幅を求める
;				破壊	AX
;				ワーク	NOW_ADPCM,DELTA_N,X_N,F_TBL
;******************************************************************************
PCM_CONV:
		_PUSH	BX,DX
		;
		AND	AX,0FH
		MOV	CS:NOW_ADPCM,AX
		AND	AX,07H
		;
		SHL	AX,1		;８倍
		INC	AX
		MUL	CS:DELTA_N
		REPT	3
		SHR	DX,1
		RCR	AX,1
		ENDM
		;
		MOV	DX,CS:X_N
		TEST	CS:NOW_ADPCM,00001000B
		JNZ	PCM_CONV_01
		ADD	AX,DX
		JNC	PCM_CONV_02
		MOV	AX,-1
		JMP	PCM_CONV_02
PCM_CONV_01:
		SUB	DX,AX
		MOV	AX,DX
		JNC	PCM_CONV_02
		XOR	AX,AX
PCM_CONV_02:
		MOV	CS:X_N,AX
		;
		MOV	BX,CS:NOW_ADPCM
		AND	BX,07H
		SHL	BX,1
		MOV	AX,CS:[BX+F_TBL]
		MUL	CS:DELTA_N
		MOV	AL,AH
		MOV	AH,DL
		CMP	AX,127
		JAE	PCM_CONV_03
		MOV	AX,127
		JMP	PCM_CONV_04
PCM_CONV_03:
		CMP	AX,24576
		JBE	PCM_CONV_04
		MOV	AX,24576
PCM_CONV_04:
		MOV	CS:DELTA_N,AX
		;
		MOV	AX,CS:X_N
		MOV	AL,AH
		_POP	BX,DX
		RET
;******************************************************************************
;		PCM停止
;******************************************************************************
PCM_ALL_STOP:
		CLI
		MOV	AX,CS
		MOV	DS,AX
		;
		CALL	BD_PCM_STOP		;PCMを停止
		STI
		RET
;******************************************************************************
;		ＨＥＸ
;******************************************************************************
HEX2:
		_PUSH	AX,DI
		MOV	DI,DX
		MOV	AL,CH
		CALL	HEX_SUB
		MOV	AL,CL
		CALL	HEX_SUB
		_POP	AX,DI
		RET
HEX1:
		_PUSH	AX,DI
		MOV	DI,DX
		CALL	HEX_SUB
		_POP	AX,DI
		RET
HEX_SUB:
		MOV	AH,AL
		SHR	AL,4
		CALL	HEX_SUB_10
		MOV	AL,AH
		AND	AL,0FH
		CALL	HEX_SUB_10
		RET
HEX_SUB_10:
		CMP	AL,10
		JAE	HEX_SUB_11
		ADD	AL,'0'
		STOSB
		RET
HEX_SUB_11:
		ADD	AL,'A'-10
		STOSB
		RET
;******************************************************************************
;		１０進変換
;******************************************************************************
VAL2:
		_PUSH	AX,CX,DX,DI
		MOV	DI,DX
		XOR	AH,AH
		MOV	DX,10000
		CALL	VAL_SUB
		MOV	DX,1000
		CALL	VAL_SUB
		MOV	DX,100
		CALL	VAL_SUB
		MOV	DX,10
		CALL	VAL_SUB
		MOV	AL,CL
		ADD	AL,'0'
		STOSB
		_POP	AX,CX,DX,DI
		RET
VAL1:
		_PUSH	AX,CX,DX,DI
		MOV	DI,DX
		XOR	AH,AH
		MOV	CX,AX
		MOV	DX,100
		CALL	VAL_SUB
		MOV	DX,10
		CALL	VAL_SUB
		MOV	AL,CL
		ADD	AL,'0'
		STOSB
		_POP	AX,CX,DX,DI
		RET
VAL_SUB:
		XOR	AL,AL
VAL_SUB_01:
		SUB	CX,DX
		JC	VAL_SUB_02
		INC	AL
		JMP	VAL_SUB_01
VAL_SUB_02:
		ADD	CX,DX
		OR	AX,AX
		JNZ	VAL_SUB_03
		MOV	AL,' '
		STOSB
		RET
VAL_SUB_03:
		ADD	AL,'0'
		STOSB
		INC	AH
		RET
;******************************************************************************
;		１０進変換
;******************************************************************************
VAL_5:
		_PUSH	AX,BX,CX,DX,DI
		MOV	DI,DX
		XOR	AH,AH
		MOV	DX,10000
		CALL	VAL_SUB
		MOV	DX,1000
		CALL	VAL_SUB
		MOV	DX,100
		CALL	VAL_SUB
		MOV	DX,10
		CALL	VAL_SUB
		MOV	AL,CL
		ADD	AL,'0'
		STOSB
		_POP	AX,BX,CX,DX,DI
		RET
VAL_5S:
		_PUSH	AX,BX,CX,DX,DI
		MOV	DI,DX
		MOV	AH,1
		MOV	DX,10000
		CALL	VAL_SUB
		MOV	DX,1000
		CALL	VAL_SUB
		MOV	DX,100
		CALL	VAL_SUB
		MOV	DX,10
		CALL	VAL_SUB
		MOV	AL,CL
		ADD	AL,'0'
		STOSB
		_POP	AX,BX,CX,DX,DI
		RET
VAL_4:
		_PUSH	AX,BX,CX,DX,DI
		MOV	DI,DX
		XOR	AH,AH
		MOV	DX,1000
		CALL	VAL_SUB
		MOV	DX,100
		CALL	VAL_SUB
		MOV	DX,10
		CALL	VAL_SUB
		MOV	AL,CL
		ADD	AL,'0'
		STOSB
		_POP	AX,BX,CX,DX,DI
		RET
VAL_4S:
		_PUSH	AX,BX,CX,DX,DI
		MOV	DI,DX
		MOV	AH,1
		MOV	DX,1000
		CALL	VAL_SUB
		MOV	DX,100
		CALL	VAL_SUB
		MOV	DX,10
		CALL	VAL_SUB
		MOV	AL,CL
		ADD	AL,'0'
		STOSB
		_POP	AX,BX,CX,DX,DI
		RET
VAL_3:
		_PUSH	AX,BX,CX,DX,DI
		MOV	DI,DX
		XOR	AH,AH
		MOV	DX,100
		CALL	VAL_SUB
		MOV	DX,10
		CALL	VAL_SUB
		MOV	AL,CL
		ADD	AL,'0'
		STOSB
		_POP	AX,BX,CX,DX,DI
		RET
VAL_3S:
		_PUSH	AX,BX,CX,DX,DI
		MOV	DI,DX
		MOV	AH,1
		MOV	DX,100
		CALL	VAL_SUB
		MOV	DX,10
		CALL	VAL_SUB
		MOV	AL,CL
		ADD	AL,'0'
		STOSB
		_POP	AX,BX,CX,DX,DI
		RET
VAL_2:
		_PUSH	AX,BX,CX,DX,DI
		MOV	DI,DX
		XOR	AH,AH
		MOV	DX,10
		CALL	VAL_SUB
		MOV	AL,CL
		ADD	AL,'0'
		STOSB
		_POP	AX,BX,CX,DX,DI
		RET
VAL_2S:
		_PUSH	AX,BX,CX,DX,DI
		MOV	DI,DX
		MOV	AH,1
		MOV	DX,10
		CALL	VAL_SUB
		MOV	AL,CL
		ADD	AL,'0'
		STOSB
		_POP	AX,BX,CX,DX,DI
		RET
;******************************************************************************
;		外部割り込みの禁止許可
;******************************************************************************
INT_DI:
		MOV	DX,ES:INT_MASK_IO
		IN	AL,DX
		OR	AL,ES:INT_MASK
		OUT	DX,AL
		RET
;******************************************************************************
;		外部割り込みの禁止許可
;******************************************************************************
INT_EI:
		MOV	DX,ES:INT_MASK_IO
		IN	AL,DX
		MOV	AH,ES:INT_MASK
		NOT	AH
		AND	AL,AH
		OUT	DX,AL
		;
		CMP	DX,0AH		;スレーブの場合
		JNZ	NOT_SLAVE_EI
		IN	AL,02H		;マスタのスレーブ割り込みを許可する
		AND	AL,01111111B
		OUT	02H,AL
NOT_SLAVE_EI:
		RET
;******************************************************************************
;		割り込みﾘｾｯﾄ
;******************************************************************************
INT_RESET:
		MOV	AL,0BH
		OUT	00H,AL
		OUT	5FH,AL		;WAIT
		IN	AL,00H
		TEST	AL,80H
		JNZ	INT_END2
INT_END1:
		MOV	AL,20H
		OUT	00H,AL
		OUT	5FH,AL		;WAIT
		JMP	INT_END3
INT_END2:
		MOV	AL,20H
		OUT	08H,AL
		OUT	5FH,AL		;WAIT
		MOV	AL,0BH
		OUT	08H,AL
		OUT	5FH,AL		;WAIT
		IN	AL,08H
		OR	AL,AL
		JZ	INT_END1
INT_END3:
		RET
;******************************************************************************
;		OPN出力
;******************************************************************************
OPN_OUT:
		_PUSH	AX,DX
		MOV	AX,DX
		MOV	DX,OPN_PORT
		PUSHF				;割り込み禁止
		CLI
		;
		CALL	OPN_WAIT
		OUT	DX,AL
		_IN_WAIT
		ADD	DX,2
		MOV	AL,AH
		OUT	DX,AL
		;
		POPF
		_POP	AX,DX
		RET
OPN_WAIT:
		PUSH	AX
OPN_WAIT_LOOP:
		IN	AL,DX
		IN	AL,DX
		OR	AL,AL
		JS	OPN_WAIT_LOOP
		POP	AX
		RET
;******************************************************************************
;		OPN初期化
;******************************************************************************
OPN_INIT:
		MOV	DH,1		;RESET
		MOV	DL,21H
		CALL	OPN_OUT
		DEC	DH
		CALL	OPN_OUT
		;
		MOV	DH,10000011B	;REG_29H SET
		MOV	DL,29H
		CALL	OPN_OUT
		;
		MOV	DH,00111100B	;TIMER SET
		MOV	DL,27H
		CALL	OPN_OUT
		;
		RET
;******************************************************************************
;		PCM_INT
;******************************************************************************
PCM_INT:
		CLI
		CLD
		_PUSH	AX,DX,DS
		MOV	AX,CS
		MOV	DS,AX
		CALL	INT_RESET		;割り込みﾘｾｯﾄ
		PUSH	CS			;ﾌｧｰｺｰﾙへ
		CALL	CS:B86I_ADR		;割り込み処理へ
		_POP	AX,DX,DS
		IRET
;******************************************************************************
;		FIFO_VOL
;******************************************************************************
FIFO_WK_GET:
		MOV	AX,CS:FIFO_VOL
		CMP	CS:BD_FLG,_86B
		JZ	FIFO_WKG_01
		SHR	AX,1
FIFO_WKG_01:
		MOV	CS:FIFO_VOL_WK,AX
		RET
;******************************************************************************
;		PCMﾊﾞｯﾌｧｸﾘﾀ
;******************************************************************************
PCM_BUFF_CLEAR:
		MOV	AX,CS
		MOV	ES,AX
		MOV	DI,OFFSET PCM_BUFF
		MOV	CX,FIFO_VOL
		SHR	CX,1
		XOR	AX,AX
		REP	STOSW
		RET
;******************************************************************************
;		REMOVE
;******************************************************************************
REMOVE_BD:
		CMP	ES:DRIVER_FLG,0
		JNZ	REMOVE_BD_09
		XOR	BX,BX
		MOV	BL,ES:BD_FLG
		SHL	BX,1
		JMP	CS:[BX+REMOVE_BD_TBL]
REMOVE_BD_09:
		RET
REMOVE_BD_TBL	DW	REMOVE_86B	;
		DW	REMOVE_WSS	;
		DW	REMOVE_SB	;
REMOVE_86B:
		CALL	INT_DI			;
		PUSH	DS
		MOV	AH,25H			;外部割り込みのベクタを戻す
		MOV	AL,ES:INT_NUM
		LDS	DX,ES:INTM_ADR
		INT	21H
		POP	DS
		RET
REMOVE_WSS:
		CALL	INT_DI			;
		PUSH	DS
		MOV	AH,25H			;外部割り込みのベクタを戻す
		MOV	AL,ES:INT_NUM
		LDS	DX,ES:INTM_ADR
		INT	21H
		POP	DS
		RET
REMOVE_SB:
		CALL	INT_DI			;
		PUSH	DS
		MOV	AH,25H			;外部割り込みのベクタを戻す
		MOV	AL,ES:INT_NUM
		LDS	DX,ES:INTM_ADR
		INT	21H
		POP	DS
		RET
;******************************************************************************
;		常駐解除開始
;******************************************************************************
REMOVE_SUB:
		CLI				;割り込み禁止
		;
		MOV	AH,12H			;全停止
		INT	7FH
		;
		CMP	ES:EMS_XMS_FLG,0	;EMSかXMSをどちらか？
		JNZ	REMOVE_SUB_01
		;
		MOV	DX,ES:EMS_HANDLE0
		MOV	AH,45H
		INT	67H
		MOV	DX,ES:EMS_HANDLE1
		MOV	AH,45H
		INT	67H
		;
		JMP	REMOVE_SUB_02
REMOVE_SUB_01:
		XOR	AL,AL			;PCM0
		CALL	XMS_DEALLOC		;XMSデアロケート
		MOV	AL,1			;PCM1
		CALL	XMS_DEALLOC		;XMSデアロケート
REMOVE_SUB_02:
		PUSH	DS
		LDS	DX,ES:INT7FH_ADR	;INT7FH を戻す
		MOV	AX,257FH
		INT	21H
		POP	DS
		;
		CALL	REMOVE_BD		;ﾎﾞｰﾄﾞ
		;
		STI				;割り込み許可
		RET
		;FMP側からのFARコール
		DW	0019			;
REMOVE_FAR:
		MOV	AX,CS
		MOV	DS,AX
		MOV	ES,AX
		CALL	REMOVE_SUB
		MOV	DX,OFFSET REMOVE_MESS
		MOV	BX,ES
		CLC
		RETF
;******************************************************************************
;		インターバルタイマーのクロックの設定
;******************************************************************************
CLOCK_SET:
		MOV	DX,CS:_10M_CLOCK	;153.6 10 MHz のウェイト
		IN	AL,42H
		TEST	AL,00100000B		;0:10MHz 1:8MHz
		JZ	CLOCK_SET_01
		MOV	DX,CS:_8M_CLOCK		;124.8 08 MHz のウェイト
CLOCK_SET_01:
		MOV	AL,00110100B		;ｶｳﾝﾀ#0,下位、上位,ﾓｰﾄﾞ2,ﾊﾞｲﾅﾘ
		OUT	77H,AL
		MOV	AL,DL
		JMP	$+2
		JMP	$+2
		OUT	71H,AL
		MOV	AL,DH
		JMP	$+2
		JMP	$+2
		OUT	71H,AL
		RET
;******************************************************************************
;		インターバルタイマーのクロックの計算
;				入力	DX	クロック(2~32)
;******************************************************************************
PCM_CLOCK_SET:
		CMP	DX,32			;2~32KHz
		JA	CLOCK_SET_R
		CMP	DX,2
		JB	CLOCK_SET_R
		;
		MOV	AX,CS
		MOV	DS,AX
		;
		MOV	BX,DX
		;
		XOR	DX,DX			;10MHz系の場合
		MOV	AX,153*16
		DIV	BX
		MOV	_10M_CLOCK,AX
		XOR	DX,DX			;08MHz系の場合
		MOV	AX,124*16
		DIV	BX
		MOV	_8M_CLOCK,AX
		;
		CALL	CLOCK_SET		;インターバル設定
		RET
CLOCK_SET_R:
		RET
;******************************************************************************
;		ｲﾝﾀｰﾊﾞﾙ割り込み
;******************************************************************************
INT08H:
		IRET
;******************************************************************************
;		SBﾚｰﾄ設定
;******************************************************************************
SB_RATE_SET:
		MOV	AX,CS
		MOV	DS,AX
		;
	SBDSP_OUT	41h			;ｻﾝﾌﾟﾘﾝｸﾞﾚｰﾄ設定
		MOV	BX,DIST_F
	SBDSP_OUT	BH
	SBDSP_OUT	BL
		RET
;******************************************************************************
;		SBﾎﾞﾘｭｰﾑ設定
;******************************************************************************
SB_VOL_SET:
		MOV	AX,CS
		MOV	DS,AX
		;
		XOR	BX,BX
		MOV	BL,PCM_VOLUME
		MOV	AL,[BX+SB_VOL_TBL]
		;
	SBMIX_OUT	04h,AL			;voice vol
	SBMIX_OUT	22h,0FFH		;master vol
		;
		RET
;******************************************************************************
;		SB再生
;******************************************************************************
SB_PCM_PLAY:
		PUSHF
		CLI
		MOV	AX,CS
		MOV	DS,AX
		;
		CALL	RATE_SET_SUB		;再生ﾚｰﾄ設定
		CALL	SB_INT_RESET		;ﾘｾｯﾄ
		CALL	SB_DSP_RESET		;DSPﾘｾｯﾄ
		;
		XOR	BX,BX
		MOV	BL,DMA_CNL
		SHL	BX,1
		ADD	BX,1
	SBMIX_OUT	81h,[BX+DMA_TBL2_SB]
		;
	SBDSP_OUT	0D1H			;ｽﾋﾟｰｶON
		;
		_PUSH	DS,ES
		CALL	PCM_BUFF_CLEAR		;ﾊﾞｯﾌｧｸﾘｱ
		CALL	SB_DATA_SET		;ﾃﾞｰﾀ設定
		CALL	SB_DATA_SET		;ﾃﾞｰﾀ設定
		
		CALL	SB_DMA_SET		;DMA設定
		_POP	DS,ES
		;
		CALL	SB_RATE_SET		;ｻﾝﾌﾟﾘﾝｸﾞﾚｰﾄ設定
		;
	SBDSP_OUT	0B6H	;bCOMMAND
	SBDSP_OUT	030H	;bMODE
	MOV	BX,FIFO_VOL_WK		;ﾊﾞｯﾌｧｻｲｽﾞ-1
	SHR	BX,1			;16bit
	DEC	BX
	SBDSP_OUT	BL
	SBDSP_OUT	BH
		;
		MOV	_PCM_FLG,1		;再生中
		POPF
		RET
;******************************************************************************
;		SB再生停止
;******************************************************************************
SB_PCM_STOP:
		PUSHF
		CLI
		_PUSH	AX,DX
		MOV	AX,CS
		MOV	DS,AX
		;
		;DMAマスクを設定する
		MOV	AL,00000100b
		OR	AL,DMA_CNL
		OUT	15H,AL			;SetSingleMask
		;
		CALL	SB_DSP_RESET		;DSPﾘｾｯﾄ
		;
		MOV	_PCM_FLG,0		;PCM停止
		_POP	AX,DX
		POPF
		RET
;******************************************************************************
;		SB_DSPのデータを得る
;			OUT	AL	ﾃﾞｰﾀ
;******************************************************************************
SB_DSP_IN:
		PUSH	DX
		MOV	DL,SB_PORT
		MOV	DH,SB_DSP_ASTS
SBDSP_IN_01:
		IN	AL,DX
		TEST	AL,80h
		JZ	SBDSP_IN_01
		MOV	DH,SB_DSP_RDAT
		IN	AL,DX
		POP	DX
		RET
;******************************************************************************
;		SB DSPへデータを設定
;			IN	AL	ﾃﾞｰﾀ
;******************************************************************************
SB_DSP_OUT:
		_PUSH	AX,DX
		MOV	AH,AL
		MOV	DL,SB_PORT
		MOV	DH,SB_DSP_STS
SBDSP_OUT_01:
		IN	AL,DX
		TEST	AL,80h
		JNZ	SBDSP_OUT_01
		MOV	AL,AH
		OUT	DX,AL
		_POP	AX,DX
		ret
;******************************************************************************
;		SBミキサーのデータを得る
;			IN	AH	ﾐｷｻｰｱﾄﾞﾚｽ
;******************************************************************************
SB_MIX_IN:
		PUSH	DX
		MOV	DL,SB_PORT
		MOV	DH,SB_MIX_ADR
		MOV	AL,AH
		OUT	DX,AL
		MOV	DH,SB_MIX_DAT
		IN	AL,DX
		POP	DX
		RET
;******************************************************************************
;		SBミキサーへデータを設定
;			OUT	AH	ﾐｷｻｰｱﾄﾞﾚｽ
;				AL	ﾃﾞｰﾀ
;******************************************************************************
SB_MIX_OUT:
		PUSH	DX
		MOV	DL,SB_PORT
		MOV	DH,SB_MIX_ADR
		XCHG	AL,AH
		OUT	DX,AL
		MOV	DH,SB_MIX_DAT
		XCHG	AL,AH
		OUT	DX,AL
		POP	DX
		RET
;******************************************************************************
;		SB DSPリセット
;			OUT	AL	割り込み番号(0~3)
;******************************************************************************
SB_DSP_RESET:
		MOV	AX,CS
		MOV	DS,AX
		;
		MOV	DL,SB_PORT		;ﾘｾｯﾄ
		MOV	DH,SB_DSP_RST
		MOV	AL,1			;26D2H <- 1
		OUT	DX,AL
		XOR	CX,CX			;ｳｪｲﾄ
		LOOP	$
		XOR	AX,AX			;26D2H <- 0
		OUT	DX,AL
		;
		XOR	CX,CX			;初期化ﾁｪｯｸ
RST_SBDSP_100:
		MOV	DH,SB_DSP_ASTS
		IN	AL,DX
		TEST	AL,80h
		JZ	RST_SBDSP_110
		MOV	DH,SB_DSP_RDAT
		IN	AL,DX
		CMP	AL,0AAH
		JZ	RST_SBDSP_200
RST_SBDSP_110:
		LOOP	RST_SBDSP_100
		STC				; 失敗
		JMP	RST_SBDSP_F00
RST_SBDSP_200:
	SBMIX_OUT	00h,00h
		;
		CALL	SB_VOL_SET		;ﾎﾞﾘｭｰﾑ設定
		;
	SBMIX_IN	80h			;INT番号の取得
		MOV	AH,AL
		XOR	AL,AL
RST_SBDSP_210:
		SHR	AH,1
		JC	RST_SBDSP_220
		INC	AL
		CMP	AL,4
		JNZ	RST_SBDSP_210
		STC				;失敗
		JMP	RST_SBDSP_F00
RST_SBDSP_220:
		CLC
RST_SBDSP_F00:
		RET
;******************************************************************************
;		FIFOﾘｾｯﾄ
;******************************************************************************
SB_INT_RESET:
		MOV	AX,CS
		MOV	DS,AX
		;
		MOV	DH,2FH			;16bit
		MOV	DL,SB_PORT		;再割り込み用
		IN	AL,DX
		RET
;******************************************************************************
;		SB割り込みﾁｪｯｸ
;******************************************************************************
SB_INT_CHECK:
		CLC
		RET
;******************************************************************************
;		SBﾃﾞｰﾀ転送
;******************************************************************************
SB_DATA_SET:
		MOV	AX,CS
		MOV	DS,AX
		;
		MOV	SI,OFFSET PCM_BUFF
		MOV	DX,0A46CH
		MOV	SI,PCM_BUFF_OFF
		MOV	CX,FIFO_VOL_WK
		SHR	CX,1
SB_DSET_01:
		MOV	AX,[SI]
		CMP	AX,00FFFH
		JG	SB_DSET_02
		CMP	AX,-0FFFH
		JL	SB_DSET_03
		SAL	AX,4			;16倍
		MOV	[SI],AX
		ADD	SI,2
		DEC	CX
		JNZ	SB_DSET_01
		JMP	SB_DSET_04
SB_DSET_02:
		MOV	WORD PTR [SI],7FFFH
		ADD	SI,2
		DEC	CX
		JNZ	SB_DSET_01
		JMP	SB_DSET_04
SB_DSET_03:
		MOV	WORD PTR [SI],8000H
		ADD	SI,2
		DEC	CX
		JNZ	SB_DSET_01
SB_DSET_04:
	XOR	PCM_BUFF_BANK,1
	MOV	AX,FIFO_VOL_WK
	MUL	PCM_BUFF_BANK
	ADD	AX,OFFSET PCM_BUFF
	MOV	PCM_BUFF_OFF,AX
		;
		RET
SB_DMA_SET:
		;DMAマスクビットをセット
		MOV	AL,00000100b
		OR	AL,DMA_CNL
		OUT	15H,AL			;SingleMaskSet
		;DMAモードを設定
		MOV	AL,01011000b
		OR	AL,DMA_CNL
		OUT	17H,AL			;ModeReg.
		;
		MOV	DX,PCM_BUFF_OFF
		MOV	BX,CS
		;
		XOR	AX,AX
		REPT	4
		SHL	BX,1
		RCL	AX,1
		ENDM
		ADD	BX,DX
		ADC	AX,0
		;DMAバンクレジスタの設定
		MOV	DX,DMA_BANK
		OUT	DX,AL			;DMA bank adr.
		OUT	19H,AL			;ClearByteF/F
		;DMAアドレスの設定
		MOV	DX,DMA_ADR
		MOV	AL,BL
		OUT	DX,AL
		MOV	AL,BH
		OUT	DX,AL			;DMA adr.
		;DMAカウンタの設定
	MOV	AX,FIFO_VOL_WK
	SHL	AX,1
	DEC	AX
		MOV	DX,DMA_CNT
		OUT	DX,AL
		MOV	AL,AH
		OUT	DX,AL			;DMA count
		;DMAマスクビットをクリア
		XOR	AL,AL
		OR	AL,DMA_CNL
		OUT	15H,AL			;SingleMaskClear
		;
		RET
;******************************************************************************
;		WSSﾚｰﾄ設定
;******************************************************************************
WSS_RATE_SET:
		;PCMレート、フォーマットの設定
		MOV	AX,CS
		MOV	DS,AX
		;
		XOR	BX,BX			;ﾚｰﾄからbitを得る
		MOV	BL,PCM_RATE
		MOV	AL,[BX+WSS_RATE_BIT]
		OR	AL,11010000B		;ｽﾃﾚｵ,16bit
		;
		PUSHF
		CLI
		MOV	AH,48H
		;なぜか2回変更しないと正常動作しない
		REPT	2
		CALL	PUT_WSS			;Fs and Playback Data Format
		CALL	WAIT_WSS		;レート変更時の同期をまつ
		ENDM
		POPF
		;
		RET
;******************************************************************************
;		WSS全体ﾎﾞﾘｭｰﾑの設定
;******************************************************************************
WSS_VOL_SET:
		MOV	AX,CS
		MOV	DS,AX
		;
		XOR	BX,BX
		MOV	BL,PCM_VOLUME
		MOV	DL,[BX+WSS_VOL_TBL]
		;
		MOV	AH,06H
		MOV	AL,DL		;L
		XOR	AL,001111111b
		CALL	PUT_WSS
		MOV	AH,07H
		MOV	AL,DL		;R
		XOR	AL,00111111b
		CALL	PUT_WSS
		RET
;******************************************************************************
;		再生
;******************************************************************************
WSS_PCM_PLAY:
		PUSHF
		CLI
		;MODE2に設定
		MOV	AX,0CC0H
		CALL	PUT_WSS			;MODE2フラグをセット
		;DACを設定
		MOV	AX,1080H
		CALL	PUT_WSS			;DAC有効,Timer無効,0dbモード
		;HPF無効に設定
		MOV	AX,1100H
		CALL	PUT_WSS			;HPF無効
		;
		CALL	RATE_SET_SUB		;再生レート設定
		CALL	WSS_VOL_SET		;全体ボリュームの設定
		CALL	WSS_INT_RESET		;INT_RESET
		;
		_PUSH	DS,ES
		CALL	PCM_BUFF_CLEAR		;ﾃﾞｰﾀｸﾘｱ
		CALL	WSS_DATA_SET		;ﾃﾞｰﾀを送る
		_POP	DS,ES
		;
		;DMA終了割り込みの許可
		MOV	AX,0A02H
		OR	AL,CS:[WSS_DEN_FLAG]	;DitherEnable
		CALL	PUT_WSS			;InterruptDisable
		;
		;PCMｽﾀｰﾄ
		MOV	BYTE PTR CS:[WSS_TRD_FLAG],00100000b
		MOV	AH,49h
		MOV	AL,00000101B		;PEN,SDC
		CALL	PUT_WSS
		XOR	AL,AL
		OR	AL,BYTE PTR CS:[WSS_TRD_FLAG]
		MOV	DX,0F44H
		OUT	DX,AL			;MCE off
		;
		MOV	_PCM_FLG,1		;再生中
		;
		POPF
		RET
;******************************************************************************
;		再生停止
;******************************************************************************
WSS_PCM_STOP:
		PUSHF
		CLI
		_PUSH	AX,DX
		;
		;DMA終了割り込みを禁止
		MOV	AX,0A00H
		OR	AL,CS:[WSS_DEN_FLAG]	;DitherEnable
		CALL	PUT_WSS			;InterruptDisable
		;DMAマスクを設定する
		MOV	AL,00000100b
		OR	AL,DMA_CNL
		OUT	15h,al			;SetSingleMask
		;PCM再生を停止
		MOV	AX,4900H
		CALL	PUT_WSS			;InterfaceConfiguration
		XOR	AL,AL
		MOV	DX,0F44H
		OUT	DX,AL			;MCE off
		MOV	DX,0F46H
		OUT	DX,AL			;割り込みフラグをクリア
		;
		MOV	_PCM_FLG,0
		;
		_POP	AX,DX
		POPF
		RET
;******************************************************************************
;		WSS出力
;	CS4231のレジスタを設定
;			IN	AH	REG
;				AL	DATA
;******************************************************************************
PUT_WSS:
		PUSHF
		CLI
		_PUSH	AX,DX
		MOV	DX,0F44H
		XCHG	AL,AH
		OR	AL,CS:[WSS_TRD_FLAG]
		OUT	DX,AL			;IndexAddressRegister
		INC	DX
		;
		XCHG	AL,AH
		OUT	DX,AL			;IndexedDataRegister
		;
		_POP	AX,DX
		POPF
		RET
;******************************************************************************
;	CS4231のINITフラグが下りるのをまつ
;******************************************************************************
WAIT_WSS:
		_PUSH	AX,CX,DX
		MOV	CX,5400
		MOV	DX,0F44H
READ_STAT_LOP:
		IN	AL,DX
		JNS	WAIT_WSS_END
		LOOP	READ_STAT_LOP
WAIT_WSS_END:
		_POP	AX,CX,DX
		RET
;******************************************************************************
;		WSS_INTﾘｾｯﾄ
;******************************************************************************
WSS_INT_RESET:
		XOR	AL,AL
		MOV	DX,0F46H
		OUT	DX,AL			;R2に書き込み
		RET
;******************************************************************************
;		WSS_INT_CHECK
;			OUT	CY=0	PCM割り込み発生
;				CY=1	PCM割り込みではない
;******************************************************************************
WSS_INT_CHECK:
		MOV	DX,0F46H
		IN	AL,DX
		TEST	AL,1
		JZ	WSS_ICK_09
		
	PUSHA
	_PUSH	ES
	MOV	AX,0A000H
	MOV	ES,AX
	MOV	DI,60*2
	MOV	CX,8
	;
	MOV	DX,0F46H
	IN	AL,DX
_01:
	MOV	DX,'0'
	SHR	AL,1
	ADC	DX,0
	MOV	ES:[DI],DX
	ADD	DI,2
	LOOP	_01
	;
	POP	ES
	POPA
		
		CLC
		RET
WSS_ICK_09:
	PUSHA
	_PUSH	ES
	MOV	AX,0A000H
	MOV	ES,AX
	MOV	DI,60*2+160
	MOV	CX,8
	;
	MOV	DX,0F46H
	IN	AL,DX
_02:
	MOV	DX,'0'
	SHR	AL,1
	ADC	DX,0
	MOV	ES:[DI],DX
	ADD	DI,2
	LOOP	_02
	;
	POP	ES
	POPA
		
		STC
		RET
		
		
		
	
;	PUSHA
;	_PUSH	ES
;	MOV	AX,0A000H
;	MOV	ES,AX
;	MOV	DI,60*2
;	MOV	CX,8
;	;
;	MOV	DX,0F46H
;	IN	AL,DX
;_01:
;	MOV	DX,'0'
;	SHR	AL,1
;	ADC	DX,0
;	MOV	ES:[DI],DX
;	ADD	DI,2
;	LOOP	_01
;	;
;	MOV	DI,60*2+160
;	MOV	CX,16
;	;
;	MOV	DX,0F43H
;	IN	AL,DX
;_02:
;	MOV	DX,'0'
;	SHR	AX,1
;	ADC	DX,0
;	MOV	ES:[DI],DX
;	ADD	DI,2
;	LOOP	_02
;	POP	ES
;	POPA
;	
		
		
		CLC
		RET
;******************************************************************************
;		ﾃﾞｰﾀ転送
;******************************************************************************
WSS_DATA_SET:
		MOV	AX,CS
		MOV	DS,AX
		;
		MOV	SI,OFFSET PCM_BUFF
		MOV	DX,0A46CH
	MOV	SI,PCM_BUFF_OFF
	MOV	CX,FIFO_VOL_WK
		SHR	CX,1
WSS_DSET_01:
		MOV	AX,[SI]
		CMP	AX,00FFFH
		JG	WSS_DSET_02
		CMP	AX,-0FFFH
		JL	WSS_DSET_03
		SAL	AX,4			;16倍
		XCHG	AL,AH
		MOV	[SI],AX
		ADD	SI,2
		DEC	CX
		JNZ	WSS_DSET_01
		JMP	WSS_DSET_04
WSS_DSET_02:
		;MOV	WORD PTR [SI],7FFFH
		MOV	WORD PTR [SI],0FF7FH
		ADD	SI,2
		DEC	CX
		JNZ	WSS_DSET_01
		JMP	WSS_DSET_04
WSS_DSET_03:
		;MOV	WORD PTR [SI],8000H
		MOV	WORD PTR [SI],0080H
		ADD	SI,2
		DEC	CX
		JNZ	WSS_DSET_01
WSS_DSET_04:
		
		;DMAマスクビットをセット
		MOV	AL,00000100b
		OR	AL,DMA_CNL
		OUT	15H,AL			;SingleMaskSet
		;DMAモードを設定
		MOV	AL,01001000b
		OR	AL,DMA_CNL
		OUT	17H,AL			;ModeReg.
		;
		MOV	DX,PCM_BUFF_OFF
		;MOV	BX,PCM_BUFF_SEG
		MOV	BX,CS
		;
		XOR	AX,AX
		REPT	4
		SHL	BX,1
		RCL	AX,1
		ENDM
		ADD	BX,DX
		ADC	AX,0
		;DMAバンクレジスタの設定
		MOV	DX,DMA_BANK
		OUT	DX,AL			;DMA bank adr.
		OUT	19H,AL			;ClearByteF/F
		;DMAアドレスの設定
		MOV	DX,DMA_ADR
		MOV	AL,BL
		OUT	DX,AL
		MOV	AL,BH
		OUT	DX,AL			;DMA adr.
		;DMAカウンタの設定
	MOV	AX,FIFO_VOL_WK
		MOV	DX,DMA_CNT
		OUT	DX,AL
		MOV	AL,AH
		OUT	DX,AL			;DMA count
		;DMAマスクビットをクリア
		XOR	AL,AL
		OR	AL,DMA_CNL
		OUT	15H,AL			;SingleMaskClear
		;
	MOV	BX,FIFO_VOL_WK
		MOV	CL,1			;ｽﾃﾚｵなら1/2
		ADD	CL,1			;16bitなら1/2
		SHR	BX,CL			;転送数ｼﾌﾄ
		DEC	BX			;-1
		MOV	AH,0EH
		MOV	AL,BH
		CALL	PUT_WSS			;DMAベースレジスタ上位8bit
		MOV	AH,0FH
		MOV	AL,BL
		CALL	PUT_WSS			;DMAベースレジスタ下位8bit
		;
	XOR	PCM_BUFF_BANK,1
	MOV	AX,FIFO_VOL_WK
	MUL	PCM_BUFF_BANK
	ADD	AX,OFFSET PCM_BUFF
	MOV	PCM_BUFF_OFF,AX
		
		RET
;******************************************************************************
;		86ﾎﾞｰﾄﾞ再生ﾚｰﾄ設定
;******************************************************************************
B86_RATE_SET:
		MOV	DX,0A468H		;出力時の再生レートの設定
		IN	AL,DX
		AND	AL,11111000B
		OR	AL,PCM_RATE
		OUT	DX,AL
		;
		RET
;******************************************************************************
;		全体ボリュームの設定
;******************************************************************************
B86_VOL_SET:
		MOV	DX,0A466H
		MOV	AL,CS:[PCM_VOLUME]
		XOR	AL,00001111B
		OR	AL,10100000B
		OUT	DX,AL			;電子ボリュームvol6設定
		;
		RET
;******************************************************************************
;		再生
;******************************************************************************
B86_PCM_PLAY:
		PUSHF
		CLI
		;
		MOV	DX,0A468H	;A468 bit7をreset（FIFO停止）
		IN	AL,DX
		OUT	5FH,AL
		AND	AL,07FH
		OUT	DX,AL
		;
		OUT	5FH,AL
		AND	AL,0BFH		;A468 bit6をreset（CPU->FIFO モード）
		OUT	DX,AL
		;
		OUT	5FH,AL
		OR	AL,8		;A468 bit3をset（FIFO リセット設定）
		OUT	DX,AL
		AND	AL,0F7H		;A468 bit3をreset（FIFO リセット解除）
		OUT	DX,AL
		;
		OUT	5FH,AL
		AND	AL,0DFH		;A468 bit5をreset（FIFO割り込み禁止
		OUT	DX,AL		;/A46A設定準備）
		;
		OUT	5FH,AL
		AND	AL,0EFH		;A468 bit4をreset（割り込みフラグ消去）
		OUT	DX,AL
		;
		MOV	DX,0A46AH	;A46A に PAN を OUT（16bit L/Rch）
		MOV	AL,10110010B
		OUT	DX,AL
		;
		CALL	B86_VOL_SET	;全体ボリュームの設定
		CALL	RATE_SET_SUB	;再生レート設定
		;
		POPF
		;
		MOV	_PCM_FLG,0
		MOV	DX,0A46CH
		XOR	AX,AX
		MOV	CX,CS:FIFO_VOL
B86_PPLAY_01:
		OUT	DX,AL			;fifo 0クリア
		LOOP	B86_PPLAY_01
		;
		PUSHF
		CLI
	;=======================================
	;	割り込み設定
	;=======================================
		MOV	DX,0A468H	;A468 bit4set（割り込みフラグ消去解除）
		IN	AL,DX
		OUT	5FH,AL
		OR	AL,10H
		OUT	DX,AL
		;
		OUT	5FH,AL
		OR	AL,20H		;A468 bit5をset（FIFO割り込み許可
		OUT	DX,AL		;/A46A設定準備）
		;
		MOV	DX,0A46AH	;A46AのFIFO割り込みサイズを設定
		MOV	AX,CS:FIFO_VOL
		SHR	AX,7
		DEC	AX
		OUT	DX,AL
	;=======================================
	;	再生開始
	;=======================================
		MOV	DX,0A468H	;A468 bit7をset（PCM 再生開始）
		IN	AL,DX
		OUT	5FH,AL
		OR	AL,80H
		OUT	DX,AL
		;
		MOV	_PCM_FLG,1	;再生中
		;
		POPF
		RET
;******************************************************************************
;		再生停止
;******************************************************************************
B86_PCM_STOP:
		PUSHF
		CLI
		_PUSH	AX,DX
		;
		MOV	DX,0A468H
		IN	AL,DX
		OUT	5FH,AL
		AND	AL,07FH
		OUT	DX,AL
		;
		OUT	5FH,AL
		OR	AL,08H		;FIFO reset
		OUT	DX,AL		;Reset処理
		OUT	5FH,AL
		AND	AL,0F7H
		OUT	DX,AL		;Reset処理おわり
		;
		OUT	5FH,AL
		AND	AL,0DFH		;FIFO 割り込み禁止
		OUT	DX,AL
		;
		OUT	5FH,AL
		AND	AL,0EFH		;FIFO 割り込みフラグreset
		OUT	DX,AL
		OUT	5FH,AL
		OR	AL,010H
		OUT	DX,AL
		;
		MOV	_PCM_FLG,0
		;
		_POP	AX,DX
		POPF
		RET
;******************************************************************************
;		インターバルタイマーの割り込みのマスク
;******************************************************************************
INT08H_DI:
		IN	AL,02H			;INT_08H 割りこみ禁止
		OR 	AL,00000001B
		OUT	02H,AL
		RET
INT08H_EI:
		IN	AL,02H			;INT_08H 割り込み許可
		AND	AL,11111110B
		OUT	02H,AL
		RET
;******************************************************************************
;		INT_CHECK
;			OUT	CY=0	PCM割り込み発生
;				CY=1	PCM割り込みではない
;******************************************************************************
B86_INT_CHECK:
		MOV	DX,0A468H		;FIFOチェック
		IN	AL,DX
		TEST	AL,00010000B
		JNZ	B86_ICK_09
		STC
		RET
B86_ICK_09:
		CLC
		RET
;******************************************************************************
;		ﾎﾞｰﾄﾞごとの割り込みﾘｾｯﾄ
;******************************************************************************
B86_INT_RESET:
		MOV	DX,0A468H	;FIFO割り込みフラグreset
		IN	AL,DX
		OUT	5FH,AL
		AND	AL,0EFH
		OUT	DX,AL		;FIFO割り込みフラグ消去
		OUT	5FH,AL
		OR	AL,010H
		OUT	DX,AL		;FIFO割り込みフラグ消去解除
		RET
;******************************************************************************
;		ﾎﾞｰﾄﾞごとのﾃﾞｰﾀ転送
;******************************************************************************
B86_DATA_SET:
		MOV	SI,OFFSET PCM_BUFF
		MOV	DX,0A46CH
		MOV	CX,CS:FIFO_VOL		;転送回数
		SHR	CX,1
B86I_1102:
		LODSW
		CMP	AX,00FFFH
		JG	B86I_1103
		CMP	AX,-0FFFH
		JL	B86I_1104
		SAL	AX,4			;16倍
		XCHG	AL,AH
		OUT	DX,AL
		XCHG	AL,AH
		OUT	DX,AL
		LOOP	B86I_1102
		JMP	B86I_1200
B86I_1103:
		MOV	AL,7FH			;MAX=7FFFH
		OUT	DX,AL
		MOV	AL,0FFH
		OUT	DX,AL
		LOOP	B86I_1102
		JMP	B86I_1200
B86I_1104:
		MOV	AL,80H			;MIN=8000H
		OUT	DX,AL
		XOR	AL,AL
		OUT	DX,AL
		LOOP	B86I_1102
B86I_1200:
		RET
;******************************************************************************
;		ﾎﾞｰﾄﾞごと処理へ
;******************************************************************************
BD_RATE_SET:
		CMP	CS:BD_FLG,1		;ﾚｰﾄ設定
		JB	B86_RATE_SET
		JZ	WSS_RATE_SET
		JMP	SB_RATE_SET
BD_VOL_SET:
		CMP	CS:BD_FLG,1		;ﾎﾞｰﾘｭｰﾑ設定
		JB	B86_VOL_SET
		JZ	WSS_VOL_SET
		JMP	SB_VOL_SET
BD_PCM_PLAY:
		CMP	CS:BD_FLG,1		;PCM再生
		JB	B86_PCM_PLAY
		JZ	WSS_PCM_PLAY
		JMP	SB_PCM_PLAY
BD_PCM_STOP:
		CMP	CS:BD_FLG,1		;PCM停止
		JB	B86_PCM_STOP
		JZ	WSS_PCM_STOP
		JMP	SB_PCM_STOP
BD_INT_CHECK:
		CMP	CS:BD_FLG,1		;PCM割り込みﾁｪｯｸ
		JB	B86_INT_CHECK
		JZ	WSS_INT_CHECK
		JMP	SB_INT_CHECK
BD_INT_RESET:
		CMP	CS:BD_FLG,1		;割り込みﾘｾｯﾄ
		JB	B86_INT_RESET
		JZ	WSS_INT_RESET
		JMP	SB_INT_RESET
BD_DATA_SET:
		CMP	CS:BD_FLG,1		;ﾃﾞｰﾀ設定
		JB	B86_DATA_SET
		JZ	WSS_DATA_SET
		JMP	SB_DATA_SET
;******************************************************************************
;		EMSにデータのある場合の処理
;		86ボードPCMのFIFO割り込みの処理
;				AX,DX は、PUSHずみとする
;				割り込みは禁止して呼び出し
;				呼び出しは、FAR CALL
;		再生は、16bitPCM,STEREO
;		レートはデフォルトで、16.54KHz
;******************************************************************************
	EVEN
B86_INT:
		CLI
		CLD
		CALL	BD_INT_CHECK		;割り込みﾁｪｯｸ
		JC	B86I_1900
		;
		CMP	CS:INT_FLG,0		;再入ﾁｪｯｸ
		JNZ	B86I_1900
		;
		MOV	CS:INT_FLG,1		;再入ﾌﾗｸﾞON
		MOV	CS:_STACK_SEG,SS	;ｽﾀｯｸ設定
		MOV	CS:_STACK_OFF,SP
		MOV	AX,CS
		MOV	SS,AX
		MOV	SP,OFFSET STACK_BOTTOM
B86_INT_01:
		STI
		;
		CMP	CS:_PCM_FLG,0		;PCM再生中か？
		JZ	B86I_1210
		;
		_PUSH	BX,CX,SI,DI,BP,DS,ES
		;
		MOV	AX,CS			;データセグメント設定
		MOV	DS,AX
		MOV	ES,AX
		;
		CMP	BD_FLG,_SB		;SB?
		JNZ	B86_INT_02
		CALL	BD_INT_RESET		;割り込みﾘｾｯﾄ
B86_INT_02:
		CMP	PCM0_USE,0		;PCM0を使っているか？
		JZ	B86I_1001
		MOV	DX,EMS_HANDLE0		;EMSハンドル0セーブ
		MOV	AH,47H
		INT	67H
B86I_1001:
		CMP	PCM1_USE,0		;PCM1を使っているか？
		JZ	B86I_1002
		MOV	DX,EMS_HANDLE1		;EMSハンドル1セーブ
		MOV	AH,47H
		INT	67H
B86I_1002:
		MOV	CX,FIFO_VOL_WK		;ワーククリア
		SHR	CX,1
		;MOV	DI,OFFSET PCM_BUFF
		MOV	DI,PCM_BUFF_OFF
		XOR	AX,AX
		REP	STOSW
		;
		MOV	ES,EMS_FRAME_SEG	;EMSフレームセグメント
		MOV	BX,OFFSET PCM_WORK
B86I_1100:
		CMP	BYTE PTR [BX+PCM_FLG],0
		JZ	B86I_1101
		MOV	PCM_WORK_ADR,BX
		;
		MOV	AX,[BX+PCM_NOW_PAGE]
		MOV	_PCM_NOW_PAGE,AX
		MOV	AX,[BX+PCM_END_PAGE]
		MOV	_PCM_END_PAGE,AX
		MOV	AX,[BX+PCM_END_OFF]
		MOV	_PCM_END_OFF,AX
		MOV	AX,[BX+PCM_VOL]
		MOV	_PCM_VOL,AL
		MOV	AX,[BX+PCM_EMS_HANDLE]
		MOV	_EMS_HANDLE,AX
		;
		PUSH	BX			;EMSハンドル設定
		MOV	DX,_EMS_HANDLE		;ハンドル
		MOV	BX,_PCM_NOW_PAGE	;ページ番号
		XOR	AL,AL			;フレームページ
		MOV	AH,44H
		INT	67H
		POP	BX
		;
		MOV	AX,[BX+PCM_ADD_L]
		MOV	BP,DS:[BX+PCM_ADD_H]
		MOV	DX,[BX+PCM_NOW_XOR]
		MOV	SI,[BX+PCM_NOW_OFF]
		;
		MOV	CX,CS:FIFO_VOL_WK	;転送回数
		SHR	CX,2
		;MOV	DI,OFFSET PCM_BUFF	;バッファドレス
		MOV	DI,CS:PCM_BUFF_OFF	;バッファドレス
		;
		MOV	BL,[BX+PCM_PAN]		;パンごとの処理へ
		XOR	BH,BH
		SHL	BX,1
		CALL	[BX+B86I_PAN_TBL]
		;
		MOV	BX,PCM_WORK_ADR
		MOV	[BX+PCM_NOW_XOR],DX
		MOV	[BX+PCM_NOW_OFF],SI
		MOV	AX,_PCM_NOW_PAGE
		MOV	[BX+PCM_NOW_PAGE],AX
B86I_1101:
		ADD	BX,PCM_WORK_VOL
		CMP	BX,OFFSET PCM_WORK+PCM_WORK_VOL*PCM_CNL_MAX
		JB	B86I_1100
		;
		CALL	BD_DATA_SET		;ﾃﾞｰﾀ転送
		;
		CMP	PCM0_USE,0		;PCM0を使っているか？
		JZ	B86I_1201
		MOV	DX,EMS_HANDLE0		;EMSハンドル0リストア
		MOV	AH,48H
		INT	67H
B86I_1201:
		CMP	PCM1_USE,0		;PCM1を使っているか？
		JZ	B86I_1202
		MOV	DX,EMS_HANDLE1		;EMSハンドル1リストア
		MOV	AH,48H
		INT	67H
B86I_1202:
		_POP	BX,CX,SI,DI,BP,DS,ES
B86I_1210:
		CLI				;割り込み禁止
		;
		CMP	BD_FLG,_SB		;SB?
		JZ	B86I_1211
		CALL	BD_INT_RESET		;割り込みﾘｾｯﾄ
B86I_1211:
		CLI
		MOV	SS,CS:_STACK_SEG	;ｽﾀｯｸ再設定
		MOV	SP,CS:_STACK_OFF
		MOV	CS:INT_FLG,0		;再入ﾌﾗｸﾞｸﾘｱ
		;
		CMP	CS:INT_LP_FLG,0		;割り込みをﾙｰﾌﾟする?
		JNZ	B86_INT
B86I_1900:
		RETF			;FARリターン
	EVEN
					;左、右
B86I_PAN_TBL	DW	B86I_P00	; 0 , 0
		DW	B86I_P01	; 1 , 0
		DW	B86I_P02	; 1 ,1/4
		DW	B86I_P03	; 1 ,2/4
		DW	B86I_P04	; 1 ,3/4
		DW	B86I_P05	; 1 , 1
		DW	B86I_P06	;3/4, 1
		DW	B86I_P07	;2/4, 1
		DW	B86I_P08	;1/4, 1
		DW	B86I_P09	; 0 , 1
	;=======================================
	;	無音
	;=======================================
B86I_P00:
		MOV	BX,PCM_WORK_ADR
		MOV	WORD PTR [BX+PCM_FLG],0
		RET
	;=======================================
	;	メインマクロ
	;=======================================
B86I_PAN	MACRO	_CALL_PAN
		LOCAL	B86I_P_01
		LOCAL	B86I_P_02
		LOCAL	B86I_P_03
		LOCAL	B86I_P_04
		LOCAL	B86I_P_05
B86I_P_01:
		MOV	BL,ES:[SI]
		MOV	BH,_PCM_VOL
		SHL	BX,1
		MOV	BX,[BX+PCM_VOL_TBL]
		_CALL_PAN
		ADD	DI,4
		;
		ADD	DX,AX
		ADC	SI,BP
		CMP	SI,4000H
		JAE	B86I_P_04
B86I_P_02:
		MOV	BX,_PCM_NOW_PAGE
		CMP	BX,_PCM_END_PAGE
		JAE	B86I_P_03
		LOOP	B86I_P_01
		RET
B86I_P_03:
		CMP	SI,_PCM_END_OFF
		JAE	B86I_P_05
		LOOP	B86I_P_01
		RET
B86I_P_04:
		;ページ切り替え
		_PUSH	AX,DX
		INC	_PCM_NOW_PAGE
		MOV	BX,_PCM_NOW_PAGE
		MOV	DX,_EMS_HANDLE
		XOR	AL,AL
		MOV	AH,44H
		INT	67H
		_POP	AX,DX
		SUB	SI,4000H
		JMP	B86I_P_02
B86I_P_05:
		MOV	BX,PCM_WORK_ADR
		CMP	WORD PTR [BX+PCM_LOOP_FLG],0
		JZ	B86I_P00
		;
		;ループする場合
		_PUSH	AX,DX
		MOV	SI,[BX+PCM_LOOP_OFF]
		MOV	BX,[BX+PCM_LOOP_PAGE]
		MOV	_PCM_NOW_PAGE,BX
		MOV	DX,_EMS_HANDLE
		XOR	AL,AL
		MOV	AH,44H
		INT	67H
		_POP	AX,DX
		;
		LOOP	B86I_P_01
		RET
		ENDM
	;=======================================
	;	PANマクロ内サブ処理
	;=======================================
PAN01		MACRO
		ADD	[DI],BX
		ENDM
PAN02		MACRO
		ADD	[DI],BX
		SAR	BX,2
		ADD	[DI+2],BX
		ENDM
PAN03		MACRO
		ADD	[DI],BX
		SAR	BX,1
		ADD	[DI+2],BX
		ENDM
PAN04		MACRO
		ADD	[DI],BX
		SAR	BX,1
		ADD	[DI+2],BX
		SAR	BX,1
		ADD	[DI+2],BX
		ENDM
PAN05		MACRO
		ADD	[DI],BX
		ADD	[DI+2],BX
		ENDM
PAN06		MACRO
		ADD	[DI+2],BX
		SAR	BX,1
		ADD	[DI],BX
		SAR	BX,1
		ADD	[DI],BX
		ENDM
PAN07		MACRO
		ADD	[DI+2],BX
		SAR	BX,1
		ADD	[DI],BX
		ENDM
PAN08		MACRO
		ADD	[DI+2],BX
		SAR	BX,2
		ADD	[DI],BX
		ENDM
PAN09		MACRO
		ADD	[DI+2],BX
		ENDM
	;=======================================
	;	マクロ展開
	;=======================================
	EVEN
B86I_P01:
	B86I_PAN	PAN01
	EVEN
B86I_P02:
	B86I_PAN	PAN02
	EVEN
B86I_P03:
	B86I_PAN	PAN03
	EVEN
B86I_P04:
	B86I_PAN	PAN04
	EVEN
B86I_P05:
	B86I_PAN	PAN05
	EVEN
B86I_P06:
	B86I_PAN	PAN06
	EVEN
B86I_P07:
	B86I_PAN	PAN07
	EVEN
B86I_P08:
	B86I_PAN	PAN08
	EVEN
B86I_P09:
	B86I_PAN	PAN09
;******************************************************************************
;		XMSにデータある場合の処理
;		86ボードPCMのFIFO割り込みの処理
;				AX,DX は、PUSHずみとする
;				割り込みは禁止して呼び出し
;				呼び出しは、FAR CALL
;		再生は、16bitPCM,STEREO
;		レートはデフォルトで、16.54KHz
;******************************************************************************
		.386P
	EVEN
B86_INT2:
		CLI
		CLD
		CALL	BD_INT_CHECK		;割り込みﾁｪｯｸ
		JC	B86_INT2_09
		;
		CMP	CS:INT_FLG,0		;多重チェック
		JNZ	B86_INT2_09
		;
		MOV	CS:INT_FLG,1		;多重フラグON
		MOV	CS:_STACK_SEG,SS	;スタツク設定
		MOV	CS:_STACK_OFF,SP
		MOV	AX,CS
		MOV	SS,AX
		MOV	SP,OFFSET STACK_BOTTOM
		STI
		;
		CMP	CS:_PCM_FLG,0		;PCM再生中か？
		JZ	B86_INT2_08
		;
		PUSHAD
		_PUSH	DS,ES
		;
		MOV	AX,CS			;データセグメント設定
		MOV	DS,AX
		MOV	ES,AX
		;
		XOR	ECX,ECX
		MOV	CX,CS:FIFO_VOL_WK	;PCMバッファのクリア
		SHR	ECX,2
		;MOV	EDI,OFFSET PCM_BUFF
		XOR	EDI,EDI
		MOV	DI,CS:PCM_BUFF_OFF
		XOR	EAX,EAX
		DB	67H
		REP	STOSD
		;
		_XMS	05H			;ローカルなA20の有効
		;
		CALL	SET_REAL4G		;4Gbyte設定
B86I2_101:
		XOR	AX,AX
		MOV	ES,AX
		MOV	BX,OFFSET PCM_WORK
B86I2_1000:
		CMP	BYTE PTR [BX+PCM_FLG],0
		JZ	B86I2_1001
		MOV	PCM_WORK_ADR,BX
		;
		MOV	EAX,[BX+PCM_END_OFF]
		MOV	DWORD PTR _PCM_END_OFF,EAX
		MOV	AX,[BX+PCM_VOL]
		MOV	_PCM_VOL,AL
		;
		MOV	AX,[BX+PCM_ADD_L]
		XOR	EBP,EBP
		MOV	BP,DS:[BX+PCM_ADD_H]
		MOV	DX,[BX+PCM_NOW_XOR]
		MOV	ESI,[BX+PCM_NOW_OFF]
		;
		MOV	CX,CS:FIFO_VOL_WK	;転送回数
		SHR	CX,2
		;MOV	DI,OFFSET PCM_BUFF	;バッファドレス
		MOV	DI,PCM_BUFF_OFF		;バッファドレス
		;
		MOV	BL,[BX+PCM_PAN]		;パンごとの処理へ
		XOR	BH,BH
		SHL	BX,1
		CALL	[BX+B86I_PAN_TBL2]
		;
		MOV	BX,PCM_WORK_ADR
		MOV	[BX+PCM_NOW_XOR],DX
		MOV	[BX+PCM_NOW_OFF],ESI
B86I2_1001:
		ADD	BX,PCM_WORK_VOL
		CMP	BX,OFFSET PCM_WORK+PCM_WORK_VOL*PCM_CNL_MAX
		JB	B86I2_1000
		;
		CALL	BD_DATA_SET		;ﾃﾞｰﾀ転送
B86_INT2_07:
		_XMS	06H			;ローカルなA20の無効
		;
		_POP	DS,ES
		POPAD
B86_INT2_08:
		CLI			;割り込み禁止
		CALL	BD_INT_RESET
		;
		CLI
		MOV	SS,CS:_STACK_SEG
		MOV	SP,CS:_STACK_OFF
		MOV	CS:INT_FLG,0
		;
		CMP	CS:INT_LP_FLG,0		;割り込みをﾙｰﾌﾟする?
		JNZ	B86_INT2
B86_INT2_09:
		RETF			;FARリターン
	EVEN
					;左、右
B86I_PAN_TBL2	DW	B86I2_P00	; 0 , 0
		DW	B86I2_P01	; 1 , 0
		DW	B86I2_P02	; 1 ,1/4
		DW	B86I2_P03	; 1 ,2/4
		DW	B86I2_P04	; 1 ,3/4
		DW	B86I2_P05	; 1 , 1
		DW	B86I2_P06	;3/4, 1
		DW	B86I2_P07	;2/4, 1
		DW	B86I2_P08	;1/4, 1
		DW	B86I2_P09	; 0 , 1
	;=======================================
	;	無音
	;=======================================
B86I2_P00:
		MOV	BX,PCM_WORK_ADR
		MOV	WORD PTR [BX+PCM_FLG],0
		RET
	;=======================================
	;	メインマクロ
	;=======================================
B86I_PAN2	MACRO	_CALL_PAN
		LOCAL	B86I_P_01
		LOCAL	B86I_P_02
		LOCAL	B86I_P_03
B86I_P_01:
		XOR	EBX,EBX
B86I_P_02:
		MOV	BL,ES:[ESI]
		MOV	BH,_PCM_VOL
		MOV	BX,[EBX*2+PCM_VOL_TBL]
		_CALL_PAN
		ADD	DI,4
		;
		ADD	DX,AX
		ADC	ESI,EBP
		CMP	ESI,DWORD PTR _PCM_END_OFF
		JAE	B86I_P_03
		LOOP	B86I_P_02
		RET
B86I_P_03:
		MOV	BX,PCM_WORK_ADR
		CMP	WORD PTR [BX+PCM_LOOP_FLG],0
		JZ	B86I2_P00
		;ループする場合
		MOV	ESI,[BX+PCM_LOOP_OFF]
		LOOP	B86I_P_01
		RET
		ENDM
	;=======================================
	;	マクロ展開
	;=======================================
	EVEN
B86I2_P01:
	B86I_PAN2	PAN01
	EVEN
B86I2_P02:
	B86I_PAN2	PAN02
	EVEN
B86I2_P03:
	B86I_PAN2	PAN03
	EVEN
B86I2_P04:
	B86I_PAN2	PAN04
	EVEN
B86I2_P05:
	B86I_PAN2	PAN05
	EVEN
B86I2_P06:
	B86I_PAN2	PAN06
	EVEN
B86I2_P07:
	B86I_PAN2	PAN07
	EVEN
B86I2_P08:
	B86I_PAN2	PAN08
	EVEN
B86I2_P09:
	B86I_PAN2	PAN09
		.186
;******************************************************************************
;		常駐部内のデータ
;******************************************************************************
	EVEN
INTM_ADR	LABEL	DWORD		;外部割り込み
INTM_OFF	DW	0		;ｵﾌｾｯﾄ
INTM_SEG	DW	0		;ｾｸﾞﾒﾝﾄ
INT7FH_ADR	LABEL	DWORD		;内部割り込み
INT7FH_OFF	DW	0		;ｵﾌｾｯﾄ
INT7FH_SEG	DW	0		;ｾｸﾞﾒﾝﾄ
INT08H_ADR	LABEL	DWORD		;内部割り込み
INT08H_OFF	DW	0		;ｵﾌｾｯﾄ
INT08H_SEG	DW	0		;ｾｸﾞﾒﾝﾄ
_STACK_ADR	LABEL	DWORD		;割り込みｽﾀｯｸ待避用
_STACK_OFF	DW	0		;ｵﾌｾｯﾄ
_STACK_SEG	DW	0		;ｾｸﾞﾒﾝﾄ
;PCM変換時のワーク
NOW_ADPCM	DW	0		;現在 の ADPCM
DELTA_N		DW	0		;DELTA_N
X_N		DW	0,0		;Xn
CONV_VOLUME	DW	256		;コンバート時のボリューム補正
F_TBL		DW	57*4,57*4,57*4,57*4,77*4,102*4,128*4,153*4

HANDLE		DW	0		;ファイル読み込み時のハンドル
PCMTMP_SEG	DW	0		;PCM読み込み用テンポラリ領域
PCMTMP_VOL	DW	8000H		;PCM読み込み用テンポラリ領域の大きさ
STAY_VOLUME	DW	0		;常駐量

OLD_DTA_ADR	LABEL	DWORD		;DTAのアドレス
OLD_DTA_OFF	DW	0		;
OLD_DTA_SEG	DW	0		;
PVI_FILE_VOL	DW	0,0		;
PVI_FILE_NAME	DW	0		;
PVI_FILE_TOP	LABEL	DWORD		;
PVI_FILE_OFF	DW	0		;
PVI_FILE_SEG	DW	0		;
PVI_FILE_FLG	DW	0		;
PVI_FILE_END	DW	0		;
PVI_FILE_ADR	DW	0		;
FILE_SENT_ADR	LABEL	DWORD		;ファイル名の転送用ワーク
FILE_SENT_OFF	DW	0		;オフセット
FILE_SENT_SEG	DW	0		;セグメント
;奇数幅ワーク
FILE_SENT_FLG	DB	0		;
_PVI		DB	'.'		;
__PVI		DB	'PVI',0		;
_PZI		DB	'.'		;
__PZI		DB	'PZI',0		;
NOW_CONV_PVI	DB	0		;
_FMP		DB	'FMP'		;FMP ヘッダー
_FMP_L		EQU	$-_FMP

PVI_MEM_MESS	DB	'PCMのメモリが足りません',13,10,'$'
REMOVE_MESS	DB	'ＰＰＺ８の常駐を解除しました。',13,10,'$'
VAL1_WK		DB	'000$'
VAL2_WK		DB	'00000$'
HEX1_WK		DB	'00$'
HEX2_WK		DB	'0000$'
HEX4_WK		DB	'00000000$'
_CR		DB	13,10,'$'
EMS_KEEP_MESS	DB	'PAGE分EMSを確保します',13,10,'$'
XMS_KEEP_MESS	DB	'Kbyte分XMSを確保します',13,10,'$'
		
_PCM_NUM	DW	0		;
_PCM_FLG	DB	0		;
_PCM_VOL	DB	0		;
_PCM_NOW_PAGE	DW	0		;
_PCM_END_PAGE	DW	0		;
_PCM_END_OFF	DW	0,0		;
_EMS_HANDLE	DW	0		;
PCM_WORK_ADR	DW	0		;
INT_FLG		DB	0		;
INT_FLG2	DB	0		;
EMS_MESS_01	DB	'EMSが登録できません',13,10,'$'
EMS_HANDLE_N0	DB	'PPZ8PVI0'	;EMSに登録するオーナー名
EMS_HANDLE_N1	DB	'PPZ8PVI1'	;EMSに登録するオーナー名
EMS_MOJI	DB	'EMMXXXX0'	;EMSチェック文字列
EMS_FLG		DB	0		;EMSの存在フラグ
EMS_NOW_PAGE	DW	0		;現在のページ番号
EMS_HANDLE0	DW	0		;EMSハンドル
EMS_HANDLE1	DW	0		;EMSハンドル
EMS_KEEP_PAGE0	DW	0		;EMSの確保したページ数
EMS_KEEP_PAGE1	DW	0		;EMSの確保したページ数
EMS_FRAME_SEG	DW	0		;EMSフレームのセグメント
PCM_VOLUME	DB	12		;全体ボリューム(DEF=12)
PCM_RATE	DB	3		;再生周波数番号
PCM_RATE_WK	DB	3		;86互換のPCMﾚｰﾄ
DIST_F		DW	16540		;再生周波数
PCME_ADR	DW	0		;PCMのヘッダーアドレス
XMS_ADR		LABEL	DWORD		;XMSのアドレス
XMS_OFF		DW	0		;XMSのアドレスオフセット
XMS_SEG		DW	0		;XMSのアドレスセグメント
XMS_HANDLE0	DW	0		;XMSのハンドル
XMS_HANDLE1	DW	0		;XMSのハンドル
XMS_FRAME_ADR0	DD	0		;XMSで確保したメモリアドレス（リニア）
XMS_FRAME_ADR1	DD	0		;XMSで確保したメモリアドレス（リニア）
XMS_KEEP_VOL0	DW	0		;XMSの確保したKbyte数
XMS_KEEP_VOL1	DW	0		;XMSの確保したKbyte数
XMS_FLG		DB	0		;XMSの存在フラグ
EMS_XMS_FLG	DB	0		;0:EMS,1:XMSか？
PCM0_USE	DB	0		;PCM0を使用中か？
PCM1_USE	DB	0		;PCM1を使用中か？
PCM0_USE_WK	DB	0		;PCM0を使用中か？
PCM1_USE_WK	DB	0		;PCM1を使用中か？
KAN_LOOK_FLG	DB	0		;環境変数を参照するか？
NOW_PCM_NUM	DB	0		;現在のPCMのワーク番号
NOW_PCM_CATE	DB	0		;現在のPCMの形式
_GDT_DS		DW	0		;前のセグメント
_GDT_ES		DW	0		;前のセグメント
_GDT_FS		DW	0		;前のセグメント
_GDT_GS		DW	0		;前のセグメント
_GDT_SS		DW	0		;前のセグメント
FIFO_VOL	DW	FIFO_DEF_VOL	;FIFOのサイズ
FIFO_VOLW	DW	FIFO_DEF_VOL	;FIFOのサイズ
FIFO_VOL_WK	DW	FIFO_DEF_VOL	;FIFOのサイズ
PVI_FILE_WADR	DW	0		;ファイル名ワークのアドレス
ADPCM_EM_FLG	DB	0		;ADPCMエミュレートフラグ
PCME_DUMMY	DD	0		;START
		DD	0		;SIZE
		DD	0FFFFFFFFH	;LOOP
		DW	16000		;RATE
REMOVE_FLG	DB	0		;
_10M_CLOCK	DW	0		;
_8M_CLOCK	DW	0		;
PUSH_REG	DW	0		;
		
DMA_CNL		DB	0		;デフォルトはDMA#0
DMA_ADR		DW	0		;DMA
DMA_CNT		DW	0		;DMA
DMA_BANK	DW	0		;DMA
WSS_TRD_FLAG	DB	00100000B	;DMA
WSS_DEN_FLAG	DB	0		;DMA
BD_FLG		DB	0		;0
INT_LP_FLG	DB	1		;

PCM_BUFF_OFF	DW	PCM_BUFF	;
PCM_BUFF_SEG	DW	0		;
PCM_BUFF_NUM	DB	0		;
PCM_BUFF_SIZE	DW	0		;
PCM_BUFF_BANK	DB	0		;
B86I_ADR	DW	B86_INT		;EMSｴﾝﾄﾘ
INT_NUM		DB	0		;FM音源の外部割り込み番号
INT_NUM2	DB	0		;FM音源の外部割り込み番号2
INT_MASK	DB	0		;外部割り込みのマスクデータ
INT_MASK_IO	DW	0		;マスクするI/Oポート
DRIVER_FLG	DB	0		;音源ﾄﾞﾗｲﾊﾞｰが常駐している
DRIVER_INT_NUM	DB	-1		;音源ﾄﾞﾗｲﾊﾞｰ外部割り込み番号

	EVEN
;前のGDTテーブル
OLD_GDT_PTR	DF	0		;前のGDTの値
;GDTテーブル
DESC_BASE	LABEL	BYTE
DESC_NULL	DESC	<>
DESC_FLAT	DESC	<0FFFFH,0,0,92H,0CFH,0>
;GDT設定用ワーク
GDT_PTR		LABEL	FWORD
GDT_PTR_LIM	DW	8*2-1
GDT_PTR_BASE	DD	0H

SB_PORT		DB	0D2H		;SBﾎﾟｰﾄ
OPN_PORT	DW	188H		;OPNﾎﾟｰﾄ
		;	IRQ,MASK,INT_NUM,INT_NUM2
INT_TBL_86B	DB	02H,00001000B,0BH,0		;INT0
		DB	0AH,00100000B,15H,6		;INT6
		DB	0AH,00000100B,12H,4		;INT41
		DB	0AH,00010000B,14H,5		;INT5
		
INT_TBL_WSS	DB	02H,00001000B,0BH,0		;INT0
		DB	02H,01000000B,0EH,2		;INT2
		DB	0AH,00000100B,12H,4		;INT41
		DB	0AH,00010000B,14H,5		;INT5
		
INT_TBL_SB	DB	02H,00001000B,0BH,0		;INT0
		DB	0AH,00000100B,12H,4		;INT41
		DB	0AH,00010000B,14H,5		;INT5
		DB	02H,00100000B,0DH,1		;INT1
		
DMA_TBL_WSS	DB	001B,01H,03H,27H	;DMA#0
		DB	010B,05H,07H,21H	;DMA#1
		DB	111B,00H,00H,00H	;DMA#2(使用不可)
		DB	011B,0DH,0FH,25H	;DMA#3

DMA_TBL_SB	DB	0,01H,03H,27H		;DMA#0
		DB	0,00H,00H,00H		;DMA#1(使用不可)
		DB	0,00H,00H,00H		;DMA#2(使用不可)
		DB	0,0DH,0FH,25H		;DMA#3

DMA_TBL2_SB	DB	00000001B,00000001B	;DMA#0
		DB	00000000B,00000000B	;DMA#1(使用不可)
		DB	00000000B,00000000B	;DMA#2(使用不可)
		DB	00000010B,01000000B	;DMA#3
		
BD_RATE_TBL	DW	RATE_TBL_86B	;86Bの再生ﾚｰﾄﾃｰﾌﾞﾙ
		DW	RATE_TBL_WSS	;WSSの再生ﾚｰﾄﾃｰﾌﾞﾙ
		DW	RATE_TBL_SB	;SBの再生ﾚｰﾄﾃｰﾌﾞﾙ

BD_RATE_TBL2	DW	RATE_TBL2_86B	;86B用86B互換のﾚｰﾄ
		DW	RATE_TBL2_WSS	;WSS用86B互換のﾚｰﾄ
		DW	RATE_TBL2_SB	;SB用86B互換のﾚｰﾄ

;再生レートテーブル
RATE_TBL2_86B	DB	0,1,2,3,4,5,6,7
RATE_TBL_86B	DW	8
		DW	44100		;0
		DW	33080		;1
		DW	22050		;2
		DW	16540		;3
		DW	11030		;4
		DW	08270		;5
		DW	05520		;6
		DW	04130		;7
		
RATE_TBL2_WSS	DB	3,5,8,10,11,13,14,15
RATE_TBL_WSS	DW	16
		DW	64000		;0
		DW	54840		;1
		DW	48000		;2
		DW	44100		;3
		DW	37800		;4
		DW	33075		;5
		DW	32000		;6
		DW	27420		;7
		DW	22050		;8
		DW	18900		;9
		DW	16000		;A
		DW	11025		;B
		DW	 9600		;C
		DW	 8000		;D
		DW	 6620		;E
		DW	 5510		;F

RATE_TBL2_SB	DB	0,1,2,3,4,5,6,7
RATE_TBL_SB	DW	8
		DW	44100		;0
		DW	33080		;1
		DW	22050		;2
		DW	16540		;3
		DW	11030		;4
		DW	08270		;5
		DW	05520		;6
		DW	04130		;7

WSS_RATE_BIT	DB	00001010B	;00 64.00kHz
		DB	00001000B	;01 54.84kHz
		DB	00001100B	;02 48.00kHz
		DB	00001011B	;03 44.10kHz
		DB	00001001B	;04 37.80kHz
		DB	00001101B	;05 33.075kHz
		DB	00000110B	;06 32.00kHz
		DB	00000100B	;07 27.42kHz
		DB	00000111B	;08 22.05kHz
		DB	00000101B	;09 18.90kHz
		DB	00000010B	;10 16.00kHz
		DB	00000011B	;11 11.025kHz
		DB	00001110B	;12  9.60kHz
		DB	00000000B	;13  8.00kHz
		DB	00001111B	;14  6.62kHz
		DB	00000001B	;15  5.51kHz

;WSSﾎﾞﾘｭｰﾑﾃｰﾌﾞﾙ
WSS_VOL_TBL	DB	00		;0
		DB	08		;1
		DB	12		;2
		DB	16		;3
		DB	20		;4
		DB	24		;5
		DB	28		;6
		DB	32		;7
		DB	36		;8
		DB	40		;9
		DB	44		;10
		DB	48		;11
		DB	52		;12
		DB	56		;13
		DB	60		;14
		DB	63		;15

SB_VOL_TBL	DB	000H,011H,022H,033H,044H,055H,066H,077H
		DB	088H,099H,0AAH,0BBH,0CCH,0DDH,0EEH,0FFH


;音程のテーブル
ONTEI_TBL	LABEL	WORD
		DW	08000H	;00 c
		DW	087A6H	;01 d-
		DW	08FB3H	;02 d
		DW	09838H	;03 e-
		DW	0A146H	;04 e
		DW	0AADEH	;05 f
		DW	0B4FFH	;06 g-
		DW	0BFCCH	;07 g
		DW	0CB34H	;08 a-
		DW	0D747H	;09 a
		DW	0E418H	;10 b-
		DW	0F1A5H	;11 b
;ADPCMエミュレートパン
ADPCM_EM_PAN	DB	0,9,1,5
;ADPCMエミュレートボリューム
ADPCM_EM_VOL	LABEL	BYTE
		INCLUDE	VOL86.INC
;ボリュームテーブル
PCM_VOL_TBL	LABEL	WORD
		INCLUDE	VOL8.INC

PVI_FILE_WK0	EQU	$				;ファイル名0
PVI_FILE_WK1	EQU	PVI_FILE_WK0+80H		;ファイル名1
PCM_WORK	EQU	PVI_FILE_WK1+80H		;ﾁｬﾈﾙのワーク
PCME_WORK0	EQU	PCM_WORK+PCM_WORK_AVOL		;PCMの音色ヘッダー0
PCME_WORK1	EQU	PCME_WORK0+PCME_DATA_VOL	;PCMの音色ヘッダー1
PCM_BUFF	EQU	PCME_WORK1+PCME_DATA_VOL	;FIFOバッファ
DTA		EQU	PCM_BUFF+80H*16			;DTA
STACK_TOP	EQU	DTA+DTA_VOL			;スタック先頭
STACK_BOTTOM	EQU	STACK_TOP+400H			;スタック後ろ
STAY_END	EQU	STACK_BOTTOM			;常駐最後
;******************************************************************************
;		コマンドラインの解釈
;******************************************************************************
COMMAND_LINE:
		CLD
		MOV	AX,CS		;バージョンを設定
		MOV	DS,AX
		MOV	ES,AX
		PRINT	MESS_TITLE	;タイトル表示
		;
		CALL	EMS_CHECK	;EMSチェック
		CALL	XMS_CHECK	;XMSチェック
		CALL	CPU_CHECK	;CPUチェック
		;
		XOR	BX,BX
		MOV	BL,DS:[80H]
		OR	BX,BX
		JZ	HELP
		MOV	BYTE PTR [BX+81H],0
		;
		MOV	SI,81H
		;
		CALL	ONE_GET
		OR	AL,AL
		JZ	HELP
		DEC	SI
		;
		CALL	ONE_GET
		AND	AL,11011111B
		CMP	AL,'R'
		JZ	REMOVE
		CMP	AL,'S'
		JZ	STAY_PARA
		DEC	SI
;******************************************************************************
;		非常駐時のパラメータ解釈
;******************************************************************************
PARA_LOOP:
		PUSH	SI
		CALL	HEADER_CHECK
		POP	SI
		JNZ	NOT_STAY
		;
		CALL	ONE_GET			;常駐時のパラメータを得る
		OR	AL,AL
		JZ	PARA_END
		CMP	AL,'-'
		JZ	NEXT_PARA
		CMP	AL,'/'
		JNZ	PARA_ERR		;パラメータエラー
NEXT_PARA:
		CALL	ONE_GET
		CMP	AL,'!'			;ステータス表示
		JZ	STATE_PARA
		AND	AL,11011111B
		CMP	AL,'L'			;PCM読み込み
		JZ	LOAD_PARA
		CMP	AL,'P'			;PCM発音
		JZ	PLAY_PARA
		CMP	AL,'S'			;PCM停止
		JZ	STOP_PARA
		CMP	AL,'I'			;ﾚｰﾄ設定
		JZ	RATE_PARA
		CMP	AL,'V'			;ﾎﾞﾘﾕｰﾑ設定
		JZ	VOLUME_PARA
;		CMP	AL,'W'			;コンバート時のボリューム補正
;		JZ	CONV_VOL_PARA
		CMP	AL,'N'			;音程設定
		JZ	NOTE_SET_PARA
		CMP	AL,'R'			;ﾙｰﾌﾟ設定
		JZ	LOOP_PARA
		CMP	AL,'T'			;PAN設定
		JZ	PAN_PARA
		CMP	AL,'A'			;全体ﾎﾞﾘｭｰﾑ設定
		JZ	AVOL_PARA
		CMP	AL,'C'			;元ﾃﾞｰﾀのﾚｰﾄ設定
		JZ	SRATE_PARA
		CMP	AL,'B'			;FIFOﾊﾞｯﾌｧｻｲｽﾞ設定
		JZ	FIFOBUFF_PARA2
;		CMP	AL,'D'			;ﾃﾞﾊﾞｯｸﾞｵﾌﾟｼｮﾝ
;		JZ	DEBUG_PARA
		;
		JMP	PARA_ERR		;ﾊﾟﾗﾒｰﾀｰｴﾗｰ
PARA_END:
		EXIT
LOAD_PARA:
		CALL	ONE_GET
		AND	AL,11011111B
		XOR	CH,CH
		CMP	AL,'A'			;ADPCM
		JZ	LOAD_PARA_01
		INC	CH
		CMP	AL,'P'			;PCM
		JNZ	PARA_ERR
LOAD_PARA_01:
		CALL	SUJI_GET		;PCMバッファ番号
		CMP	AX,2
		JAE	PARA_ERR
		MOV	CL,AL
		CALL	ONE_GET
		CMP	AL,','
		JNZ	PARA_ERR
		CALL	ONE_GET
		DEC	SI
		MOV	DX,SI
		CALL	ONE_SKIP
		MOV	BYTE PTR [SI],0
		XOR	AL,AL			;環境変数をてみ読み込み
		MOV	AH,3
		INT	7FH
		JC	LOAD_PARA_ERR
		;
		JMP	PARA_LOOP
PLAY_PARA:
		CALL	SUJI_GET
		CMP	AX,PCM_CNL_MAX
		JAE	PARA_ERR
		MOV	BP,AX
		CALL	SUJI_GET
		CMP	AX,256
		JAE	PARA_ERR
		;
		MOV	CH,AL
		AND	CX,8000H
		AND	AX,007FH
		OR	AX,CX
		;
		MOV	DX,AX
		MOV	AX,BP
		MOV	AH,1
		INT	7FH
		;
		JMP	PARA_LOOP
STOP_PARA:
		CALL	SUJI_GET
		CMP	AX,PCM_CNL_MAX
		JAE	PARA_ERR
		;
		MOV	AH,2
		INT	7FH
		;
		JMP	PARA_LOOP
RATE_PARA:
		CALL	SUJI_GET
		CMP	AX,8
		JAE	PARA_ERR
		;
		MOV	DX,AX
		MOV	AH,14H
		INT	7FH
		JMP	PARA_LOOP
VOLUME_PARA:
		CALL	SUJI_GET
		CMP	AX,PCM_CNL_MAX
		JAE	PARA_ERR
		MOV	BP,AX
		CALL	SUJI_GET
		CMP	AX,16
		JAE	PARA_ERR
		MOV	DX,AX
		MOV	AX,BP
		MOV	AH,7
		INT	7FH
		;
		JMP	PARA_LOOP
CONV_VOL_PARA:
		CALL	SUJI_GET
		MOV	DX,AX
		MOV	AH,0AH
		INT	7FH
		;
		JMP	PARA_LOOP
NOTE_SET_PARA:
		CALL	SUJI_GET
		CMP	AX,PCM_CNL_MAX
		JAE	PARA_ERR
		MOV	BP,AX
		CALL	SUJI_GET
		CMP	AX,12*8
		JAE	PARA_ERR
		;
		MOV	CX,AX
		MOV	DL,12
		IDIV	DL
		XOR	BX,BX
		MOV	BL,AH
		SHL	BX,1
		ADD	BX,OFFSET ONTEI_TBL
		XOR	DX,DX
		XOR	CX,CX
		MOV	CL,AL
		MOV	AX,[BX]
		;
		CMP	CL,3
		JZ	OCT_SHIFT_03
		JA	OCT_SHIFT_01
		MOV	BL,3
		SUB	BL,CL
		MOV	CL,BL
		SHR	AX,CL
		JMP	OCT_SHIFT_03
OCT_SHIFT_01:
		SUB	CX,3
OCT_SHIFT_02:
		SHL	AX,1
		RCL	DX,1
		LOOP	OCT_SHIFT_02
OCT_SHIFT_03:
		MOV	CX,AX
		;
		MOV	AX,BP
		MOV	AH,0BH
		INT	7FH
		;
		JMP	PARA_LOOP
LOOP_PARA:
		CALL	SUJI_GET
		CMP	AX,PCM_CNL_MAX
		JAE	PARA_ERR
		MOV	BP,AX
		;
		CALL	ONE_GET
		DEC	SI
		CALL	SUJI_CHECK
		JNC	LOOP_PARA_01
		MOV	DX,-1
		MOV	CX,-1
		JMP	LOOP_PARA_03
LOOP_PARA_01:
		CALL	SUJI_GET
		XOR	DX,DX
		MOV	CX,AX
		;
		CALL	ONE_GET
		DEC	SI
		CALL	SUJI_CHECK
		JNC	LOOP_PARA_02
		MOV	DI,-1
		MOV	BX,-1
		JMP	LOOP_PARA_03
LOOP_PARA_02:
		CALL	SUJI_GET
		XOR	DI,DI
		MOV	BX,AX
LOOP_PARA_03:
		PUSH	SI
		MOV	SI,BX
		MOV	AX,BP
		MOV	AH,0EH
		INT	7FH
		POP	SI
		;
		JMP	PARA_LOOP
STATE_PARA:
		CALL	HEADER_CHECK		;ヘッダーのチェックへ
		JNZ	PARA_ERR
		;
		CALL	STATUS_PUT		;ステータス表示
		;
		MOV	AX,4C00H
		INT	21H
PAN_PARA:
		CALL	SUJI_GET
		CMP	AX,PCM_CNL_MAX
		JAE	PARA_ERR
		MOV	BP,AX
		CALL	SUJI_GET
		CMP	AX,10
		JAE	PARA_ERR
		MOV	DX,AX
		MOV	AX,BP
		MOV	AH,13H
		INT	7FH
		JMP	PARA_LOOP
AVOL_PARA:
		CALL	SUJI_GET
		CMP	AX,16
		JAE	PARA_ERR
		MOV	AH,16H
		INT	7FH
		JMP	PARA_LOOP
SRATE_PARA:
		CALL	SUJI_GET
		MOV	DX,AX
		MOV	AH,15H
		INT	7FH
		JMP	PARA_LOOP
FIFOBUFF_PARA2:
		CALL	SUJI_GET		;64Kを越えるとエラー
		OR	AX,AX
		JZ	PARA_ERR
		CMP	AX,16
		JA	PARA_ERR
		;
		XOR	DX,DX			;FIFOﾊﾞｯﾌｧの変更
		MOV	DL,AL
		SHL	DX,7
		MOV	AH,20H
		INT	7FH
		JC	PARA_ERR
		;
		JMP	PARA_LOOP
	;=======================================
	;	デバッグ用
	;=======================================
DEBUG_PARA:
		JMP	PARA_LOOP
;******************************************************************************
;		常駐時のパラメータ解釈
;******************************************************************************
STAY_PARA:
		CALL	ONE_GET			;常駐時ﾊﾟﾗﾒｰﾀを得る
		OR	AL,AL
		JZ	STAY
		CMP	AL,'-'
		JZ	STAY_PARA_01
		CMP	AL,'/'
		JNZ	PARA_ERR		;ﾊﾟﾗﾒｰﾀｰｴﾗｰ
STAY_PARA_01:
		CALL	ONE_GET
		AND	AL,11011111B
		CMP	AL,'T'			;PCMﾃﾝﾎﾟﾗﾘｻｲｽﾞ設定
		JZ	PCMTMP_PARA
		CMP	AL,'X'			;XMSを使用するか
		JZ	COMXMS_PARA
		CMP	AL,'B'			;FIFOのﾊﾞｯﾌｧの大きさ
		JZ	FIFOBUFF_PARA
		CMP	AL,'I'			;ﾚｰﾄ設定
		JZ	RATE_PARA2
		CMP	AL,'D'			;ｻｳﾝﾄﾞﾌﾞﾗｽﾀｰDMA設定
		JZ	SB_DMA_PARA
		CMP	AL,'F'			;外部割り込みを設定しない
		JZ	FMP_FLG_PARA
;		CMP	AL,'C'			;86ﾎﾞｰﾄﾞのﾁｪｯｸをしない
;		JZ	B86_CK_PARA
		JMP	PARA_ERR
PCMTMP_PARA:
		CALL	SUJI_GET		;PCMﾃﾝﾎﾟﾗﾘｻｲｽﾞを得る
		MOV	DX,1024
		MUL	DX
		JC	PARA_ERR
		MOV	PCMTMP_VOL,AX
		MOV	PCMTMP_FLG,1
		JMP	STAY_PARA
FIFOBUFF_PARA:
		CALL	SUJI_GET		;FIFOﾊﾞﾂﾌｧｻｲｽﾞを得る
		OR	AX,AX
		JZ	PARA_ERR
		CMP	AX,16
		JA	PARA_ERR
		SHL	AX,7
		MOV	FIFO_VOL,AX
		MOV	FIFO_VOLW,AX
		CALL	FIFO_WK_GET
		JMP	STAY_PARA
COMXMS_PARA:
		MOV	COMXMS_FLG,1		;XMSを使用する
		JMP	STAY_PARA
RATE_PARA2:
		CALL	SUJI_GET		;ﾚｰﾄ設定
		CMP	AX,8
		JAE	PARA_ERR
		;
		MOV	PCM_RATE_FLG,1		;ﾚｰﾄ設定あり?
		MOV	PCM_RATE_WK,AL
		JMP	STAY_PARA
FMP_FLG_PARA:
		;MOV	FMP_FLG,1		;常駐チェックをしない
		MOV	DRIVER_FLG,-1
		JMP	STAY_PARA
B86_CK_PARA:
		MOV	B86_CK_FLG,1		;86ボードチェックをしない
		JMP	STAY_PARA
SB_DMA_PARA:
		CALL	SUJI_GET		;ｻｳﾝﾄﾞﾌﾞﾗｽﾀｰDMA番号
		OR	AX,AX
		JZ	SBDMA_PARA_01
		CMP	AX,3
		JNZ	PARA_ERR
SBDMA_PARA_01:
		MOV	DMA_CNL,AL
		JMP	STAY_PARA
;******************************************************************************
;		常駐
;******************************************************************************
STAY:
		;CMP	FMP_FLG,0		;FMPが常駐してなくても
		;JNZ	FMP_STAY_CK		;常駐出来るか？
		;
		CALL	MDZ_CHECK		;MDZﾁｪｯｸ
		JC	STAY_01
		PRINT	MESS_35
		JMP	STAY_03
STAY_01:
		CALL	PMD_CHECK		;PMDﾁｪｯｸ
		JC	STAY_02
		PRINT	MESS_36
		JMP	STAY_03
STAY_02:
		CALL	FMP_CHECK		;FMPﾁｪｯｸ
		JC	STAY_03
		PRINT	MESS_34
		CMP	PCMTMP_FLG,0		;FMPがいるとﾃﾝﾎﾟﾗﾘをなくす
		JNZ	STAY_03
		MOV	PCMTMP_VOL,0
STAY_03:
	;=======================================
	;	音源ボードのチェック
	;=======================================
;		CMP	B86_CK_FLG,0		;ボードのチェック無視
;		JNZ	BOURD_CK_09
		;
		MOV	DX,0A460H		;86B,WSSﾁｪｯｸ
		IN	AL,DX
		AND	AL,0F0H
		MOV	AH,AL
		OR	AL,00000001B		;OPNA使用許可
		OUT	DX,AL
		;
		MOV	OPN_PORT,188H
		CMP	AH,01000000B		;0100xxxxb 9801-86(188H)
		JZ	B86_CHECK
		MOV	OPN_PORT,288H
		CMP	AH,01010000B		;0101xxxxb 9801-86(288H)
		JZ	B86_CHECK
		MOV	OPN_PORT,188H
		CMP	AH,01100000B		;0110xxxxb 9821Np
		JZ	WSS_CHECK
		MOV	OPN_PORT,188H
		CMP	AH,01110000B		;0111xxxxb 9821Xt,Xa,Xn,Xp,Xs
		JZ	WSS_CHECK
		MOV	OPN_PORT,188H
		CMP	AH,10000000B		;1000xxxxb 9821Cf,Cx,Cb
		JZ	WSS_CHECK
		;
		CALL	SB_DSP_RESET		;SBﾁｪｯｸ
		JNC	SB_CHECK
		;
		JMP	NOT_BOURD		;ボードが存在しない
B86_CHECK:
		MOV	B86_FLG,1		;86ﾎﾞｰﾄﾞがある
		MOV	BD_FLG,_86B		;86ﾎﾞｰﾄﾞ選択
		PRINT	MESS_31
		JMP	BOURD_CK_09
WSS_CHECK:
		MOV	WSS_FLG,1		;WSSがある
		MOV	BD_FLG,_WSS		;WSS選択
		PRINT	MESS_32
		JMP	BOURD_CK_09
SB_CHECK:
		MOV	SB_FLG,1		;SBがある
		MOV	BD_FLG,_SB		;SB選択
		PRINT	MESS_33
		JMP	BOURD_CK_09
BOURD_CK_09:
	;=======================================
	;	二重常駐のチェック
	;=======================================
		CALL	HEADER_CHECK		;ヘッダーのチェックへ
		JZ	STAYED
		MOV	INT7FH_OFF,BX		;INT_D2H の値を保存
		MOV	INT7FH_SEG,ES
	;=======================================
	;	常駐量の計算
	;=======================================
		MOV	DX,OFFSET STAY_END	;プログラム部
		ADD	DX,15
		SHR	DX,4
		MOV	AX,CS			;PCMTMPのセグメント
		ADD	AX,DX
		MOV	PCMTMP_SEG,AX
		MOV	AX,PCMTMP_VOL		;+PCMTMPの大きさ
		SHR	AX,4			;(64Kbyte以内)
		ADD	DX,AX
		MOV	STAY_VOLUME,DX		;常駐量
	;=======================================
	;	メモリ量のチェック
	;=======================================
		MOV	AX,CS			;メモリブロックの変更
		MOV	ES,AX
		MOV	BX,DX
		MOV	AH,4AH
		INT	21H
		JC	MEMORY_ERR
	;=======================================
	;	EMS&XMSチェック
	;=======================================
		CMP	COMXMS_FLG,0	;XMSを使用するか？
		JNZ	STAY_11
		CMP	EMS_FLG,0	;EMSはあるか？
		JZ	NOT_EMS_ERR
		MOV	EMS_XMS_FLG,0
		;
		MOV	BX,1			;1ﾍﾟｰｼﾞだけ
		MOV	EMS_KEEP_PAGE0,BX
		MOV	AH,43H			;EMSｱﾛｹｰﾄ
		INT	67H
		OR	AH,AH
		JNZ	EMS_ALLOC_ERR
		MOV	EMS_HANDLE0,DX
		MOV	SI,OFFSET EMS_HANDLE_N0
		MOV	AX,5301H		;ハンドル名の登録
		INT	67H
		OR	AH,AH
		JNZ	EMS_ALLOC_ERR
		;
		MOV	BX,1			;1ﾍﾟｰｼﾞだけ
		MOV	EMS_KEEP_PAGE1,BX
		MOV	AH,43H			;EMSｱﾛｹｰﾄ
		INT	67H
		OR	AH,AH
		JNZ	EMS_ALLOC_ERR
		MOV	EMS_HANDLE1,DX
		MOV	SI,OFFSET EMS_HANDLE_N1
		MOV	AX,5301H		;ハンドル名の登録
		INT	67H
		OR	AH,AH
		JNZ	EMS_ALLOC_ERR
		;
		PRINT	MESS_20
		JMP	STAY_12
STAY_11:
		CMP	XMS_FLG,0	;XMSはあるか？
		JZ	NOT_XMS_ERR
		CMP	CPU_NUM,_386	;386以上か？
		JB	CPU_ERR
		CMP	CPU_VM_FLG,0	;仮想86でないか？
		JNZ	CPU_ERR
		CALL	GDT_CALC	;GDT設定
		MOV	B86I_ADR,OFFSET B86_INT2	;ｴﾝﾄﾘをXMSに
		MOV	EMS_XMS_FLG,1
		PRINT	MESS_22
STAY_12:
	;=======================================
	;	常駐開始
	;=======================================
		CLI
		MOV	AX,CS
		MOV	DS,AX
		MOV	AX,257FH		;INT7FH を設定
		MOV	DX,OFFSET INT7FH
		INT	21H
		;
		CALL	STAY_BD			;ﾎｰﾄﾞごとの常駐処理
		;
		CALL	FIFO_WK_GET		;FIFO計算
		CALL	WORK_INIT		;PCMﾜｰｸ初期化
		CALL	RATE_SET_SUB2		;再生ﾚｰﾄ設定
		STI				;割り込み許可
	;=======================================
	;	タスク設定
	;=======================================
		CALL	FMP_CHECK		;FMPﾁｪｯｸ
		JC	STAY_21
		MOV	SI,OFFSET PPZ_STR
		MOV	CL,TASK_ASIN
		MOV	DX,OFFSET REMOVE_FAR
		MOV	AH,SERVICE_NON
		MOV	AL,10H
		INT	0D2H
		JC	TASK_ERR		;ﾀｽｸｴﾗｰ
STAY_21:
		PRINT	MESS_01			;常駐時のメッセージ
		CMP	INT_USE_FLG,0
		JNZ	STAY_22
		PRINT	MESS_37
		JMP	STAY_23
STAY_22:
		MOV	AX,CS
		MOV	ES,AX
		MOV	DX,OFFSET MESS_38_WK
		MOV	AL,INT_NUM
		CALL	HEX1
		PRINT	MESS_38
STAY_23:
		MOV	AH,49H			;環境領域の解放
		MOV	ES,CS:[2CH]
		INT	21H
		;
		CLD
		MOV	AX,CS			;オーナー名登録
		MOV	DS,AX
		MOV	ES,AX
		MOV	DI,80H
		MOV	AX,2020H
		MOV	CX,80H/2
		REP	STOSW
		MOV	SI,OFFSET COM_LINE_DAT
		MOV	DI,80H
		MOV	CX,COM_LINE_L
		REP	MOVSB
		;
		MOV	DX,STAY_VOLUME
		MOV	AX,3100H		;常駐終了
		INT	21H
;******************************************************************************
;		STAY
;******************************************************************************
STAY_BD:
		XOR	BX,BX
		MOV	BL,BD_FLG
		SHL	BX,1
		JMP	CS:[BX+STAY_BD_TBL]
STAY_BD_09:
		RET
STAY_BD_TBL	DW	STAY_86B	;
		DW	STAY_WSS	;
		DW	STAY_SB		;
	;=======================================
	;	86B
	;	INT_USE_NUM	0:INT0 拡張バス
	;			1:INT6 マウス
	;			2:INT4 640Kフロッピー
	;			3:INT5 FM音源
	;=======================================
STAY_86B:
		MOV	DX,OPN_PORT		;外部割り込みの選択
		MOV	AL,0EH
		OUT	DX,AL
		_IN_WAIT
		ADD	DX,2
		IN	AL,DX
		_IN_WAIT
		AND	AX,11000000B
		SHR	AX,6-2
		;
		MOV	BX,AX
		MOV	AL,[BX+INT_TBL_86B+2]
		MOV	INT_NUM,AL
		MOV	AL,[BX+INT_TBL_86B+3]
		MOV	INT_NUM2,AL
		XOR	AX,AX
		MOV	AL,[BX+INT_TBL_86B+0]
		MOV	INT_MASK_IO,AX
		MOV	AL,[BX+INT_TBL_86B+1]
		MOV	INT_MASK,AL
		;
		CMP	DRIVER_FLG,0		;ﾄﾞﾗｲﾊﾞｰがいる?
		JNZ	STAY_BD_09
		;
		CLI
		;
		MOV	INT_USE_FLG,1		;外部割り込み使用ﾌﾗｸﾞON
		MOV	AH,35H			;外部割り込みの確保
		MOV	AL,INT_NUM
		INT	21H
		MOV	INTM_OFF,BX
		MOV	INTM_SEG,ES
		MOV	AH,25H			;外部割り込みの設定
		MOV	AL,INT_NUM
		MOV	DX,OFFSET PCM_INT
		INT	21H
		;
		CALL	OPN_INIT		;OPN初期化
		MOV	AX,CS
		MOV	ES,AX
		CALL	INT_EI			;割り込み禁止
		;
		STI				;割り込み許可
		RET
	;=======================================
	;	WSS
	;	INT_USE_NUM	0:INT0 拡張バス
	;			1:INT2 
	;			2:INT4 640Kフロッピー
	;			3:INT5 FM音源
	;=======================================
STAY_WSS:
		MOV	DX,0F40H		;割り込み番号を得る
		IN	AL,DX
		AND	AX,0011100B
		XOR	BX,BX
		CMP	AX,08H
		JZ	STAY_WSS_01
		ADD	BX,4
		CMP	AX,10H
		JZ	STAY_WSS_01
		ADD	BX,4
		CMP	AX,18H
		JZ	STAY_WSS_01
		ADD	BX,4
STAY_WSS_01:
		MOV	AL,[BX+INT_TBL_WSS+2]
		MOV	INT_NUM,AL
		MOV	AL,[BX+INT_TBL_WSS+3]
		MOV	INT_NUM2,AL
		XOR	AX,AX
		MOV	AL,[BX+INT_TBL_WSS+0]
		MOV	INT_MASK_IO,AX
		MOV	AL,[BX+INT_TBL_WSS+1]
		MOV	INT_MASK,AL
		;
		XOR	BX,BX			;DMA番号を得る
		MOV	BL,DMA_CNL
		SHL	BX,2
		MOV	DX,0F40H
		IN	AL,DX
		AND	AL,11111000B
		OR	AL,[BX+DMA_TBL_WSS+0]
		OUT	DX,AL
		XOR	AX,AX
		MOV	AL,[BX+DMA_TBL_WSS+1]
		MOV	DMA_ADR,AX
		MOV	AL,[BX+DMA_TBL_WSS+2]
		MOV	DMA_CNT,AX
		MOV	AL,[BX+DMA_TBL_WSS+3]
		MOV	DMA_BANK,AX
		;
		CMP	DRIVER_FLG,0		;ﾄﾞﾗｲﾊﾞｰがいる?
		JNZ	STAY_BD_09
		;
		MOV	AL,INT_NUM		;割り込み番号が同じ?
		CMP	AL,DRIVER_INT_NUM
		JZ	STAY_BD_09
		;
		CLI
		;
		MOV	INT_USE_FLG,1		;外部割り込み使用ﾌﾗｸﾞON
		MOV	AH,35H			;外部割り込みの確保
		MOV	AL,INT_NUM
		INT	21H
		MOV	INTM_OFF,BX
		MOV	INTM_SEG,ES
		MOV	AH,25H			;外部割り込みの設定
		MOV	AL,INT_NUM
		MOV	DX,OFFSET PCM_INT
		INT	21H
		;
		MOV	AX,CS
		MOV	ES,AX
		CALL	INT_EI			;割り込み禁止
		STI				;割り込み許可
		RET
	;=======================================
	;	SB
	;	INT_USE_NUM	0:INT0  拡張バス
	;			1:INT41 640Kフロッピー
	;			2:INT5  FM音源
	;			3:INT1 
	;=======================================
STAY_SB:
		MOV	AX,SB_RESET_FLG
		AND	AX,3
		SHL	AX,2
		;
		MOV	BX,AX
		MOV	AL,[BX+INT_TBL_SB+2]
		MOV	INT_NUM,AL
		MOV	AL,[BX+INT_TBL_SB+3]
		MOV	INT_NUM2,AL
		XOR	AX,AX
		MOV	AL,[BX+INT_TBL_SB+0]
		MOV	INT_MASK_IO,AX
		MOV	AL,[BX+INT_TBL_SB+1]
		MOV	INT_MASK,AL
		;
		XOR	BX,BX
		MOV	BL,DMA_CNL
		SHL	BX,2
		;
		XOR	AX,AX
		MOV	AL,[BX+DMA_TBL_SB+1]
		MOV	DMA_ADR,AX
		MOV	AL,[BX+DMA_TBL_SB+2]
		MOV	DMA_CNT,AX
		MOV	AL,[BX+DMA_TBL_SB+3]
		MOV	DMA_BANK,AX
		;
		MOV	INT_LP_FLG,0		;割り込み処理はﾙｰﾌﾟしない
		;
		CMP	DRIVER_FLG,0		;ﾄﾞﾗｲﾊﾞｰがいる?
		JNZ	STAY_BD_09
		;
		MOV	AL,INT_NUM		;割り込み番号が同じ?
		CMP	AL,DRIVER_INT_NUM
		JZ	STAY_BD_09
		;
		CLI
		;
		MOV	INT_USE_FLG,1		;外部割り込み使用ﾌﾗｸﾞON
		MOV	AH,35H			;外部割り込みの確保
		MOV	AL,INT_NUM
		INT	21H
		MOV	INTM_OFF,BX
		MOV	INTM_SEG,ES
		MOV	AH,25H			;外部割り込みの設定
		MOV	AL,INT_NUM
		MOV	DX,OFFSET PCM_INT
		INT	21H
		;
		MOV	AX,CS
		MOV	ES,AX
		CALL	INT_EI			;割り込み禁止
		STI				;割り込み許可
		RET
;******************************************************************************
;		常駐解除
;******************************************************************************
REMOVE:
	;=======================================
	;	非常駐のチェック
	;=======================================
		CALL	HEADER_CHECK		;ヘッダーのチェックへ
		JNZ	NOT_STAY
		;
		CMP	ES:REMOVE_FLG,0		;常駐解除チェック
		JNZ	REMOVE_SKIP
	;=======================================
	;	FMP のチェック
	;=======================================
		CALL	DRIVER_STOP		;FMP のチェック
		;
		CALL	FMP_CHECK		;FMPタスク開放
		JC	TASK_REMOVE_01
		MOV	SI,OFFSET PPZ_STR
		MOV	CL,TASK_DEASIN
		MOV	AL,10H
		INT	0D2H
TASK_REMOVE_01:
		CALL	REMOVE_SUB		;開放ルーチン
		;
		MOV	AH,49H			;プログラム領域の解放
		INT	21H
		;
		PRINT	MESS_02			;メッセージ出力
REMOVE_SKIP:
		MOV	AX,4C00H		;DOS EXIT
		INT	21H
;******************************************************************************
;		常駐部のヘッダーチェック
;			出力	ZF=0	常駐していない
;				ZF=1	常駐している
;					ES:BX	前の常駐物のアドレス
;			破壊	AX,BX,CX,DI,SI,ES
;******************************************************************************
HEADER_CHECK:
		MOV	AX,357FH		;INT7FH の値を得る
		INT	21H
		MOV	SI,OFFSET _PSGPCMZ	;常駐ﾁｪｯｸ
		MOV	DI,BX
		ADD	DI,2
		MOV	CX,_PSGPCMZ_L
		REPZ	CMPSB
		RET
;******************************************************************************
;		ｽﾃｰﾀｽ表示
;				IN	ES	PPZ8ｾｸﾞﾒﾝﾄ
;******************************************************************************
STATUS_PUT:
		PRINT	MESS_ST_01		;ﾀｲﾄﾙ
		;
		PRINT	MESS_ST_02		;PVI0_NAME
		MOV	AL,ES:PCM0_USE_WK
		MOV	SI,OFFSET PVI_FILE_WK0
		CALL	ST_PUT_10
		;
		PRINT	MESS_ST_03		;PVI1_NAME
		MOV	AL,ES:PCM1_USE_WK
		MOV	SI,OFFSET PVI_FILE_WK1
		CALL	ST_PUT_10
		;
		PRINT	MESS_ST_06		;再生レート
		XOR	BX,BX
		MOV	BL,ES:PCM_RATE
		SHL	BX,1
		MOV	DX,[BX+MESS_STBL_01]
		MOV	AH,9
		INT	21H
		;
		PRINT	MESS_ST_07		;全体ボリューム
		MOV	AL,ES:PCM_VOLUME
		CALL	VAL1_PRINT
		PRINT	_CR
		;
		PRINT	MESS_ST_08		;FIFOサイズ
		MOV	AX,ES:FIFO_VOL
		SHR	AX,7
		CALL	VAL1_PRINT
		PRINT	_CR
		;
		PRINT	MESS_ST_09		;使用メモリ
		XOR	BX,BX
		MOV	BL,ES:EMS_XMS_FLG
		SHL	BX,1
		MOV	DX,[BX+MESS_STBL_02]
		MOV	AH,9
		INT	21H
		;
		PRINT	MESS_ST_10		;テンポラリサイズ
		MOV	CX,ES:PCMTMP_VOL
		CALL	VAL2_PRINT
		PRINT	_CR
		;
		PRINT	MESS_ST_11		;ﾁｬﾈﾙ情報
		;
		CALL	ST_PUT_20
		;
		MOV	AX,4C00H
		INT	21H
ST_PUT_10:
		OR	AL,AL
		JZ	ST_PUT_13
		MOV	DI,OFFSET MESS_ST_WK
		MOV	CX,80H
ST_PUT_11:
		MOV	AL,ES:[SI]
		OR	AL,AL
		JZ	ST_PUT_12
		MOV	[DI],AL
		INC	SI
		INC	DI
		LOOP	ST_PUT_11
ST_PUT_12:
		MOV	BYTE PTR [DI],'$'
		PRINT	MESS_ST_WK
		PRINT	_CR
		RET
ST_PUT_13:
		PRINT	MESS_ST_13
		RET
ST_PUT_20:
		MOV	BX,OFFSET PCM_WORK
		XOR	BP,BP
ST_PUT_21:
		MOV	AX,BP
		ADD	AL,'0'
		MOV	MESS_ST_12+00,AL
		MOV	AL,ES:[BX+PCM_FLG]
		MOV	DX,OFFSET MESS_ST_12+02
		CALL	ST_PUT_30
		MOV	AX,ES:[BX+PCM_NUM]
		SHR	AX,15
		ADD	AL,'0'
		MOV	MESS_ST_12+06,AL
		MOV	AX,ES:[BX+PCM_NUM]
		AND	AX,7FH
		MOV	DX,OFFSET MESS_ST_12+08
		CALL	VAL1_PUT
		MOV	CX,ES:[BX+PCM_VOL]
		MOV	DX,OFFSET MESS_ST_12+12
		PUSH	ES
		MOV	AX,CS
		MOV	ES,AX
		MOV	DI,DX
		CALL	VAL_2
		POP	ES
		MOV	CX,ES:[BX+PCM_ADDS_H]
		MOV	DX,OFFSET MESS_ST_12+15
		CALL	HEX2_PUT
		MOV	CX,ES:[BX+PCM_ADDS_L]
		MOV	DX,OFFSET MESS_ST_12+19
		CALL	HEX2_PUT
		MOV	AX,ES:[BX+PCM_PAN]
		ADD	AL,'0'
		MOV	MESS_ST_12+25,AL
		MOV	CX,ES:[BX+PCM_SORC_F]
		MOV	DX,OFFSET MESS_ST_12+27
		CALL	VAL2_PUT
		MOV	AL,ES:[BX+PCM_LOOP_FLG]
		MOV	DX,OFFSET MESS_ST_12+33
		CALL	ST_PUT_30
		;
		CMP	BYTE PTR ES:[BX+PCM_LOOP_FLG],0
		JNZ	ST_PUT_22
		PUSH	ES
		MOV	AX,CS
		MOV	ES,AX
		MOV	AL,'-'
		MOV	CX,9
		MOV	DI,OFFSET MESS_ST_12+37
		REP	STOSB
		MOV	CX,9
		MOV	DI,OFFSET MESS_ST_12+47
		REP	STOSB
		POP	ES
		JMP	ST_PUT_23
ST_PUT_22:
		MOV	CX,ES:[BX+PCM_LOOP_START+2]
		MOV	DX,OFFSET MESS_ST_12+37
		CALL	HEX2_PUT
		MOV	CX,ES:[BX+PCM_LOOP_START+0]
		MOV	DX,OFFSET MESS_ST_12+41
		CALL	HEX2_PUT
		MOV	MESS_ST_12+45,'h'
		MOV	CX,ES:[BX+PCM_LOOP_END+2]
		MOV	DX,OFFSET MESS_ST_12+47
		CALL	HEX2_PUT
		MOV	CX,ES:[BX+PCM_LOOP_END+0]
		MOV	DX,OFFSET MESS_ST_12+51
		CALL	HEX2_PUT
		MOV	MESS_ST_12+55,'h'
ST_PUT_23:
		MOV	AX,ES:[BX+PCM_NUM]
		MOV	CL,ES:PCM0_USE_WK
		MOV	DI,OFFSET PCME_WORK0+PZI_TBL_TOP
		OR	AX,AX
		JNS	ST_PUT_24
		MOV	CL,ES:PCM1_USE_WK
		MOV	DI,OFFSET PCME_WORK1+PZI_TBL_TOP
ST_PUT_24:
		OR	CL,CL
		JNZ	ST_PUT_25
		PUSH	ES
		MOV	AX,CS
		MOV	ES,AX
		MOV	AL,'-'
		MOV	CX,9
		MOV	DI,OFFSET MESS_ST_12+57
		REP	STOSB
		MOV	CX,9
		MOV	DI,OFFSET MESS_ST_12+67
		REP	STOSB
		POP	ES
		JMP	ST_PUT_26
ST_PUT_25:
		AND	AX,7FH
		MOV	DX,AX			;BX 音色テーブルアドレス
		SHL	DX,1
		SHL	AX,4
		ADD	AX,DX
		ADD	DI,AX
		;
		MOV	CX,ES:[DI+2]
		MOV	DX,OFFSET MESS_ST_12+57
		CALL	HEX2_PUT
		MOV	CX,ES:[DI+0]
		MOV	DX,OFFSET MESS_ST_12+61
		CALL	HEX2_PUT
		MOV	MESS_ST_12+65,'h'
		MOV	CX,ES:[DI+6]
		MOV	DX,OFFSET MESS_ST_12+67
		CALL	HEX2_PUT
		MOV	CX,ES:[DI+4]
		MOV	DX,OFFSET MESS_ST_12+71
		CALL	HEX2_PUT
		MOV	MESS_ST_12+75,'h'
ST_PUT_26:
		PRINT	MESS_ST_12
		;
		ADD	BX,PCM_WORK_VOL
		INC	BP
		CMP	BP,PCM_CNL_MAX
		JNZ	ST_PUT_21
		;
		RET
ST_PUT_30:
		XOR	AH,AH
		SHL	AX,1
		MOV	DI,AX
		MOV	SI,[DI+MESS_STBL_03]
		MOV	DI,DX
		MOV	AX,[SI]
		MOV	[DI],AX
		MOV	AL,[SI+2]
		MOV	[DI+2],AL
		RET
;******************************************************************************
;		メッセージ出力
;******************************************************************************
PARA_ERR:
		PRINT	MESS_07			;パラメータエラー
		MOV	AX,4C01H
		INT	21H
HELP:
		PRINT	MESS_06			;ヘルプ
		MOV	AX,4C01H
		INT	21H
STAYED:
		PRINT	MESS_03			;すでに常駐している
		MOV	AX,4C01H
		INT	21H
NOT_STAY:
		PRINT	MESS_04			;常駐してない
		MOV	AX,4C01H
		INT	21H
MEMORY_ERR:
		PRINT	MESS_15			;メモリが足んない
		MOV	AX,4C01H
		INT	21H
LOAD_PARA_ERR:
		AND	AX,3
		MOV	BX,AX
		SHL	BX,1
		MOV	DX,[BX+LOAD_ERR_TBL]
		MOV	AH,9
		INT	21H
		PRINT	MESS_16			;読み込みに失敗
		MOV	AX,4C01H
		INT	21H
NOT_BOURD:
		PRINT	MESS_08			;音源ボードがない
		MOV	AX,4C01H
		INT	21H
FMP_OLD:
		PRINT	MESS_19			;FMPが古い
		MOV	AX,4C01H
		INT	21H
TASK_ERR:
		PRINT	MESS_18			;タスクエラー
		MOV	AX,4C01H
		INT	21H
NOT_EMS_ERR:
		PRINT	MESS_23			;EMSエラー
		MOV	AX,4C01H
		INT	21H
NOT_XMS_ERR:
		PRINT	MESS_24			;XMSエラー
		MOV	AX,4C01H
		INT	21H
CPU_ERR:
		PRINT	MESS_25			;CPUエラー
		MOV	AX,4C01H
		INT	21H
EMS_ALLOC_ERR:
		PRINT	MESS_26			;EMS_ALLOCエラー
		MOV	AX,4C01H
		INT	21H
;******************************************************************************
;		1文字得る
;				IN	DS:SI	文字列
;				OUT	AL	文字
;******************************************************************************
ONE_GET:
		LODSB
		CMP	AL,' '
		JZ	ONE_GET
		CMP	AL,09H
		JZ	ONE_GET
		RET
;******************************************************************************
;		1文字飛ばす
;				IN	DS:SI	文字列
;				OUT	AL	文字
;******************************************************************************
ONE_SKIP:
		LODSB
		OR	AL,AL
		JZ	ONE_SKIP_R
		CMP	AL,' '
		JZ	ONE_SKIP_R
		CMP	AL,09H
		JZ	ONE_SKIP_R
		JMP	ONE_SKIP
ONE_SKIP_R:
		DEC	SI
		RET
;******************************************************************************
;		数字ﾁｪｯｸ
;				IN	AL	文字
;				OUT	CY=0	数値
;					CY=1	数値以外
;******************************************************************************
SUJI_CHECK:
		CMP	AL,'$'
		JZ	SUJI_IS
		CMP	AL,'%'
		JZ	SUJI_IS
		CMP	AL,'0'
		JB	NOT_SUJI
		CMP	AL,'9'
		JA	NOT_SUJI
		CMP	AL,'+'
		JZ	SUJI_IS
		CMP	AL,'-'
		JZ	SUJI_IS
SUJI_IS:
		CLC			;数値なら	CF=0
		RET
NOT_SUJI:
		STC			;数値以外なら	CF=1
		RET
;******************************************************************************
;		数値を得る
;				IN	DS:SI	オフセット
;				OUT	AX	数値
;******************************************************************************
SUJI_GET:
		MOV	MINUS_FLG,0
		CALL	ONE_GET
		CMP	AL,'+'
		JZ	SUJI_GET_02
		CMP	AL,'-'
		JZ	SUJI_GET_01
		DEC	SI
		JMP	SUJI_GET_02
SUJI_GET_01:
		MOV	MINUS_FLG,1
SUJI_GET_02:
		CALL	SUJI_GETS
		;
		CMP	MINUS_FLG,0
		JZ	SUJI_PLUS
		NEG	AX
SUJI_PLUS:
		RET
;******************************************************************************
;		数字を得る
;			IN	DS:SI	文字列
;			OUT	CY=0	正常終了
;					AX	数字
;				CY=1	ｴﾗｰ
;******************************************************************************
SUJI_GETS:
		CALL	ONE_GET
		CMP	AL,'$'
		JZ	HEX_GET
		CMP	AL,'%'
		JZ	BIN_GET
		;
		CMP	AL,'0'
		JB	PARA_ERR
		CMP	AL,'9'
		JA	PARA_ERR
		;
		DEC	SI
		_PUSH	CX,DX
		XOR	CX,CX
SUJI_GET_LOOP:
		XOR	AX,AX
		LODSB
		CMP	AL,'0'
		JB	SUJI_GETR
		CMP	AL,'9'
		JA	SUJI_GETR
		XOR	AH,AH
		SUB	AL,'0'
		MOV	DX,CX
		SHL	CX,2
		ADD	CX,DX
		SHL	CX,1
		ADD	CX,AX
		JMP	SUJI_GET_LOOP
SUJI_GETR:
		DEC	SI
		MOV	AX,CX
		_POP	CX,DX
		CLC
		RET
;******************************************************************************
;		16進数を得る
;******************************************************************************
HEX_GET:
		PUSH	CX
		XOR	CX,CX
HEX_GET_01:
		XOR	AX,AX
		LODSB
		CMP	AL,'0'
		JB	HEX_GET_04
		CMP	AL,'9'
		JA	HEX_GET_02
		SUB	AL,'0'
		JMP	HEX_GET_03
HEX_GET_02:
		AND	AL,11011111B
		CMP	AL,'A'
		JB	HEX_GET_04
		CMP	AL,'Z'
		JA	HEX_GET_04
		SUB	AL,'A'-10
HEX_GET_03:
		SHL	CX,4
		ADD	CX,AX
		JMP	HEX_GET_01
HEX_GET_04:
		DEC	SI
		MOV	AX,CX
		POP	CX
		RET
;******************************************************************************
;		2進数を得る
;******************************************************************************
BIN_GET:
		PUSH	CX
		XOR	CX,CX
BIN_GET_01:
		XOR	AX,AX
		LODSB
		CMP	AL,'0'
		JB	BIN_GET_02
		CMP	AL,'1'
		JA	BIN_GET_02
		SUB	AL,'0'
		SHL	CX,1
		ADD	CX,AX
		JMP	BIN_GET_01
BIN_GET_02:
		DEC	SI
		MOV	AX,CX
		POP	CX
		RET
;******************************************************************************
;		数値表示
;******************************************************************************
VAL1_PRINT:
		MOV	DX,OFFSET VAL1_WK
		CALL	VAL1_PUT
		PRINT	VAL1_WK
		RET
VAL2_PRINT:
		MOV	DX,OFFSET VAL2_WK
		CALL	VAL2_PUT
		PRINT	VAL2_WK
		RET
HEX1_PRINT:
		MOV	DX,OFFSET HEX1_WK
		CALL	HEX1_PUT
		PRINT	HEX1_WK
		RET
HEX2_PRINT:
		MOV	DX,OFFSET HEX2_WK
		CALL	HEX2_PUT
		PRINT	HEX2_WK
		RET
VAL1_PUT:
		_PUSH	DI,ES
		MOV	DI,CS
		MOV	ES,DI
		CALL	VAL1
		_POP	DI,ES
		RET
VAL2_PUT:
		_PUSH	DI,ES
		MOV	DI,CS
		MOV	ES,DI
		CALL	VAL2
		_POP	DI,ES
		RET
HEX1_PUT:
		_PUSH	DI,ES
		MOV	DI,CS
		MOV	ES,DI
		CALL	HEX1
		_POP	DI,ES
		RET
HEX2_PUT:
		_PUSH	DI,ES
		MOV	DI,CS
		MOV	ES,DI
		CALL	HEX2
		_POP	DI,ES
		RET
;******************************************************************************
;		HEX
;			IN	AX	数値
;				ES:DI	書き込みアドレス
;******************************************************************************
;HEX:
		PUSH	AX
		MOV	AL,AH
		CALL	HEX_10
		POP	AX
HEX_10:
		MOV	AH,AL
		SHR	AL,4
		CALL	HEX_11
		MOV	AL,AH
		AND	AL,15
HEX_11:
		CMP	AL,10
		JAE	HEX_12
		ADD	AL,'0'
		STOSB
		RET
HEX_12:
		ADD	AL,'A'-10
		STOSB
		RET
;******************************************************************************
;		CPUﾁｪｯｸ
;			OUT	CPU_NUM		CPUの番号
;				CPU_VM_FLG	仮想86か？
;******************************************************************************
CPU_CHECK:
		MOV	CPU_VM_FLG,0
		;
		MOV	AL,01H		;V30 or 286,386,486
		MOV	CL,20H
		SHR	AL,CL
		OR	AL,AL
		JZ	_V30_IS
		;
		PUSHF			;286 or 386,486
		POP	AX
		PUSHF
		OR	AX,4000H
		PUSH	AX
		POPF
		PUSHF
		POP	AX
		POPF
		AND	AX,0C000H
		CMP	AX,4000H
		JNZ	_286_IS
		;
		.386P
		;
		MOV	BX,SP		;386 or 486
		AND	SP,0FFFCH
		PUSHFD
		CLI
		PUSHFD
		POP	EAX
		OR	EAX,00040000H
		PUSH	EAX
		POPFD
		PUSHFD
		POP	EAX
		POPFD
		MOV	SP,BX
		TEST	EAX,00040000H
		JZ	_386_IS
		.186
_486_IS:
		MOV	CPU_NUM,_486
		CALL	VM_CHECK
		JMP	CPU_CK_09
_386_IS:
		MOV	CPU_NUM,_386
		CALL	VM_CHECK
		JMP	CPU_CK_09
_286_IS:
		MOV	CPU_NUM,_286
		JMP	CPU_CK_09
_V30_IS:
		MOV	CPU_NUM,_V30
CPU_CK_09:
		RET
		.386P
VM_CHECK:
		SMSW	AX
		TEST	AL,1
		JNZ	VM_CK_01
		MOV	CPU_VM_FLG,0
		RET
VM_CK_01:
		MOV	CPU_VM_FLG,1
		RET
		.186
;******************************************************************************
;		常駐部外のデータ
;******************************************************************************
MINUS_FLG	DB	0		;+/-
FMP_FLG		DB	0		;FMPﾁｪｯｸする?
B86_CK_FLG	DB	0		;86ﾎﾞｰﾄﾞﾁｪｯｸすね?
COMXMS_FLG	DB	0		;XMSを使用するか?
CPU_NUM		DB	0		;00:V30,01:286,02:386,03:486
CPU_VM_FLG	DB	0		;00:ﾘｱﾙﾓｰﾄﾞ,01:仮想86ﾓｰﾄﾞ
PCMTMP_FLG	DB	0		;ﾃﾝﾎﾟﾗﾘ設定が呼ばれた
B86_FLG		DB	0		;86Bﾌﾗｸﾞ
WSS_FLG		DB	0		;WSSﾌﾗｸﾞ
SB_FLG		DB	0		;SBﾌﾗｸﾞ
SB_RESET_FLG	DW	0		;SBﾘｾｯﾄﾌﾗｸﾞ
PCM_RATE_FLG	DB	0		;ﾚｰﾄ設定あり
INT_USE_FLG	DB	0		;外部割り込み使用ﾌﾗｸﾞ

PPZ_STR		DB	'PPZ8'		;FMP設定用ｵｰﾅｰ名
COM_LINE_DAT	LABEL	BYTE
		DB	COM_LINE_L-1
		DB	'PPZ8  v'
COM_LINE_VER	DB	_PPZ8_VER
		DB	'  (C)Ukky'
COM_LINE_L	EQU	$-COM_LINE_DAT

MESS_TITLE	DB	'- PPZ8.COM - ver'
MESS_VER	DB	_PPZ8_VER
		DB	' Programed by UKKY(KGB-1373)',13,10,'$'
MESS_01		DB	'常駐します',13,10,'$'
MESS_02		DB	'常駐解除します',13,10,'$'
MESS_03		DB	'すでに常駐しています',13,10,'$'
MESS_04		DB	'常駐されていません',13,10,'$'
MESS_05		DB	'割り込みがすでに設定されています',13,10,'$'
MESS_06		LABEL	BYTE
	DB	'Usage)  PPZ8 {S|R} {-,/ option}  (S:常駐,R:常駐解除)',13,10
	DB	'常駐時Option)',13,10
	DB	'  -Tn            読み込み用ﾃﾝﾎﾟﾗﾘの大きさ',13,10
	DB	'  -X             XMSを使用します',13,10
	DB	'  -Bn(1~16)      FIFOﾊﾞｯﾌｧの大きさ',13,10
	DB	'  -In(0~7)       再生ﾚｰﾄ設定',13,10
	DB	'  -Dn(0,3)       ｻｳﾝﾄﾞﾌﾞﾗｽﾀｰのDMAﾁｬﾈﾙ設定',13,10
	DB	'  -F             外部割り込みを使用しない',13,10
	DB	'ｺﾏﾝﾄﾞOption)  [c(0~7) PCMﾁｬﾈﾙ番号]',13,10
	DB	'  -LAn(0~1),(filename) PVIﾌｧｲﾙの読み込み',13,10
	DB	'  -LPn(0~1),(filename) PZIﾌｧｲﾙの読み込み',13,10
	DB	'  -Pc p(0~127)   PCMの発音',13,10
	DB	'  -Sc            PCMの停止',13,10
	DB	'  -Vc v(0~15)    ﾎﾞﾘｭｰﾑ変更',13,10
	DB	'  -Nc n(0~95)    PCMの音程変更',13,10
	DB	'  -Tc n(0~9)     PANの設定',13,10
	DB	'  -Rc sa(start_adr) ea(end_adr) ﾙｰﾌﾟﾎﾟｲﾝﾀの設定',13,10
	DB	'  -Cc n(0~65535) 元ﾃﾞｰﾀのﾚｰﾄ設定',13,10
	DB	'  -In(0~7)       再生ﾚｰﾄ設定',13,10
	DB	'  -An(0~15)      全体ﾎﾞﾘｭｰﾑの設定',13,10
	DB	'  -Bn(1~16)      FIFOﾊﾞｯﾌｧの大きさ変更',13,10
	DB	'  -!             ｽﾃｰﾀｽを見る',13,10
	DB	'$'
MESS_07		DB	'ｽｲｯﾁの指定が違います',13,10,'$'
MESS_08		DB	'86B/WSS/SBがありません',13,10,'$'
MESS_11		DB	'を使用します',13,10,'$'
MESS_15		DB	'ﾒﾓﾘが足りません',13,10,'$'
MESS_16		DB	'読み込みに失敗しました',13,10,'$'
MESS_17		DB	'FMPが常駐してません',13,10,'$'
MESS_18		DB	'FMPのﾀｽｸが登録できません',13,10,'$'
MESS_19		DB	'FMPのﾊﾞｰｼﾞｮﾝが古いです',13,10,'$'
MESS_20		DB	'EMSを使用します',13,10,'$'
MESS_22		DB	'XMSを使用します',13,10,'$'
MESS_23		DB	'EMSが使用できません',13,10,'$'
MESS_24		DB	'XMSが使用できません',13,10,'$'
MESS_25		DB	'XMS使用時は、386以降のﾘｱﾙﾓｰﾄﾞでしか動作しません'
		DB	13,10,'$'
MESS_26		DB	'EMSが登録できません',13,10,'$'
LOAD_ERR_TBL	DW	MESS_27
		DW	MESS_28
		DW	MESS_29
		DW	MESS_30
MESS_27		DB	'ﾌｧｲﾙ読み込み中にｴﾗｰが発生しました',13,10,'$'
MESS_28		DB	'PVI/PZIのﾃﾞｰﾀ形式が違います',13,10,'$'
MESS_29		DB	'ﾒﾓﾘが確保できません',13,10,'$'
MESS_30		DB	'EMSﾊﾝﾄﾞﾙのﾏｯﾋﾟﾝｸﾞができません',13,10,'$'
MESS_31		DB	'86B_PCMを認識しました',13,10,'$'
MESS_32		DB	'WSS_PCMを認識しました',13,10,'$'
MESS_33		DB	'SB_PCMを認識しました',13,10,'$'
MESS_34		DB	'FMPを認識しました',13,10,'$'
MESS_35		DB	'MDZを認識しました',13,10,'$'
MESS_36		DB	'PMDを認識しました',13,10,'$'
MESS_37		DB	'INT7FH を使用します',13,10,'$'
MESS_38		DB	'INT7FH,INT'
MESS_38_WK	DB	'xxHを使用します',13,10,'$'

MESS_STBL_01	DW	MESS_ST_14
		DW	MESS_ST_15
		DW	MESS_ST_16
		DW	MESS_ST_17
		DW	MESS_ST_18
		DW	MESS_ST_19
		DW	MESS_ST_20
		DW	MESS_ST_21

MESS_STBL_02	DW	MESS_ST_22
		DW	MESS_ST_23

MESS_STBL_03	DW	MESS_ST_24
		DW	MESS_ST_25

MESS_ST_01	DB	'======== PPZ8 ｽﾃｰﾀｽ ========',13,10,'$'
MESS_ST_02	DB	'PVI0_name =$'
MESS_ST_03	DB	'PVI1_name =$'
MESS_ST_04	DB	'PVI0ｻｲｽﾞ  =$'
MESS_ST_05	DB	'PVI1ｻｲｽﾞ  =$'
MESS_ST_06	DB	'再生ﾚｰﾄ   =$'
MESS_ST_07	DB	'全体ﾎﾞﾘｭｰﾑ=$'
MESS_ST_08	DB	'FIFOｻｲｽﾞ  =$'
MESS_ST_09	DB	'使用ﾒﾓﾘ   =$'
MESS_ST_10	DB	'ﾃﾝﾎﾟﾗﾘｻｲｽﾞ=$'
MESS_ST_11	LABEL	BYTE
 DB 'C|key|B|num|Vl|  rate   |P|SRate|Lop| lp_start|  lp_end |pcm_start| pcm_size|'
 DB 13,10,'$'
MESS_ST_12	LABEL	BYTE
 ;   0         1         2         3         4         5         6         7
 ;   01234567890123456789012345678901234567890123456789012345678901234567890123456
 DB '0|OFF|0|000|00|00000000h|0|00000|OFF|00000000h|00000000h|00000000h|00000000h|'
 DB 13,10,'$'
MESS_ST_13	DB	' - Nothing -',13,10,'$'
MESS_ST_14	DB	'44.1Khz',13,10,'$'
MESS_ST_15	DB	'33.08Khz',13,10,'$'
MESS_ST_16	DB	'22.05Khz',13,10,'$'
MESS_ST_17	DB	'16.54Khz',13,10,'$'
MESS_ST_18	DB	'11.03Khz',13,10,'$'
MESS_ST_19	DB	'8.27Khz',13,10,'$'
MESS_ST_20	DB	'5.52Khz',13,10,'$'
MESS_ST_21	DB	'4.13Khz',13,10,'$'

MESS_ST_22	DB	'EMS',13,10,'$'
MESS_ST_23	DB	'XMS',13,10,'$'
MESS_ST_24	DB	'off'
MESS_ST_25	DB	' on'

MESS_ST_WK	DB	100H	DUP(?)
;******************************************************************************
;		おしまい
;******************************************************************************
CODE		ENDS
		END	START
