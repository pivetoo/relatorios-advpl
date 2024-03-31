#Include 'Protheus.ch'
#Include 'TopConn.ch'

/*{Protheus.doc} Trpt02
Este módulo permite imprimir um relatório de pedidos por cliente, mostrando o código e nome do cliente na primeira seção 
e os detalhes dos pedidos (número, descrição do produto, quantidade e preço de venda) na segunda seção.

@author Rogério Piveto
@since 10/02/2024
@version 1.0
*/

User Function TRpt02()

    Local oReport   := Nil
    Local cPergs    := Padr("TRPT02", 10)

    Pergunte(cPergs, .F.) // SX1

    oReport := RPTStruc(cPergs)
    oReport:PrintDialog()
    
Return

Static Function RPTPrint(oReport)

    Local oSection1 := oReport:Section(1)
    Local oSection2 := oReport:Section(2)
    Local cQuery    := ""
    Local cNumCod   := ""

    cQuery :=  " SELECT " + CRLF
    cQuery +=       " A1_COD " + CRLF
    cQuery +=       " , A1_NOME " + CRLF
    cQuery +=       " , C5_NUM " + CRLF
    cQuery +=       " , C6_QTDVEN " + CRLF
    cQuery +=       " , C6_PRCVEN " + CRLF
    cQuery +=       " , B1_DESC " + CRLF
    cQuery +=  " FROM SA1990 SA1 " + CRLF
    cQuery +=       " , SC5990 SC5 " + CRLF
    cQuery +=       " , SC6990 SC6 " + CRLF
    cQuery +=       " , SB1990 SB1 " + CRLF
    cQuery +=  " WHERE SA1.D_E_L_E_T_ = ' ' " + CRLF
    cQuery +=       " AND C5_FILIAL = '" +MV_PAR01+ "' " + CRLF
    cQuery +=       " AND SC5.D_E_L_E_T_ = ' ' " + CRLF
    cQuery +=       " AND C5_CLIENTE = A1_COD " + CRLF
    cQuery +=       " AND C6_FILIAL = '" +MV_PAR01+ "' " + CRLF
    cQuery +=       " AND SC6.D_E_L_E_T_ = ' ' " + CRLF
    cQuery +=       " AND C6_NUM = C5_NUM " + CRLF
    cQuery +=       " AND SB1.D_E_L_E_T_ = ' ' " + CRLF 
    cQuery +=       " AND B1_COD = C6_PRODUTO "+ CRLF
    cQuery +=  " ORDER BY " + CRLF
    cQuery +=       " B1_FILIAL " + CRLF
    cQuery +=       " , A1_COD " + CRLF
    cQuery +=       " , C5_FILIAL " + CRLF
    cQuery +=       " , C5_NUM " + CRLF
    cQuery +=       " , C6_FILIAL " + CRLF
    cQuery +=       " , C6_ITEM " + CRLF

    // Verifica se a tabela ja está aberta
    If Select("TEMP") <> 0
        DBSelectArea("Temp")
        DBCloseArea()
    EndIf

    TCQUERY cQuery New ALIAS "TEMP"

        DBSelectArea("TEMP")
        TEMP->(dbGoTop())

        oReport:SetMeter(TEMP->(LastRec()))
    
    While !EOF()
        If oReport:Cancel()
            Exit
        EndIf
        // Iniciando a primeira seção
        oSection1:Init()
        oReport:IncMeter()

        cNumCod := TEMP->A1_COD
        IncProc("Imprimindo Cliente "+ AllTrim(TEMP->A1_COD))

        // Imprimindo a primeira seção
        oSection1:Cell("A1_COD"):SetValue(TEMP->A1_COD)
        oSection1:Cell("A1_NOME"):SetValue(TEMP->A1_NOME)
        oSection1:Printline()

        // Iniciar a impressão da seção 2
        oSection2:Init()
        // Verifica se o código do cliente é o mesmo, se sim, imprime os dados do pedido
        While TEMP->A1_COD == cNumCod
            oReport:IncMeter()

            IncProc("Imprimindo pedidos..."+ AllTrim(TEMP->C5_NUM))
            oSection2:Cell("C5_NUM"):SetValue(TEMP->C5_NUM)
            oSection2:Cell("B1_DESC"):SetValue(TEMP->B1_DESC)
            oSection2:Cell("C6_PRCVEN"):SetValue(TEMP->C6_PRCVEN)
            oSection2:Cell("C6_QTDVEN"):SetValue(TEMP->C6_QTDVEN)
            oSection2:Printline()

            TEMP->(dbSkip())
        EndDo
        oSection2:Finish()
        oReport:ThinLine()

        oSection1:Finish()
    EndDo
    
Return

Static Function RPTStruc(cNome)

    Local oReport   := Nil
    Local oSection1 := Nil
    Local oSection2 := Nil
    Local cTitulo   := "Relátorio de pedidos por clientes"
    Local cHelp     := "Descrição do Help"

    oReport := TReport():New(cNome, cTitulo, cNome, {|oReport| RPTPrint(oReport)}, cHelp)
    
    oReport:SetPortrait() // Definindo a orientação por retrato

    oSection1 := TRSection():New(oReport, "Clientes",{"SA1"}, Nil, .F., .T.)
    TRCell():New(oSection1, "A1_COD", "TEMP", "Código", "@!", 40)
    TRCell():New(oSection1, "A1_NOME", "TEMP", "Nome", "@!", 200)

    oSection2 := TRSection():New(oReport, "Produtos",{"SC5", "SC6", "SB1"}, Nil, .F., .T.)
    TRCell():New(oSection2, "C5_NUM", "TEMP", "Pedido", "@!", 200)
    TRCell():New(oSection2, "B1_DESC", "TEMP", "Descrição", "@!", 200)
    TRCell():New(oSection2, "C6_QTDVEN", "TEMP", "Quantidade", "@E 999999.99", 200)
    TRCell():New(oSection2, "C6_PRCVEN", "TEMP", "Prec. Venda", "@E 999999.99", 200)

    oSection1:SetPageBreak(.F.) // Quebra de seção

Return (oReport)
