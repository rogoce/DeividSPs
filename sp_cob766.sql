-- Bandera que activa Texto en recibos.
-- Creado    : 27/10/2011 - Autor: Henry Giron
DROP PROCEDURE sp_cob766;
CREATE PROCEDURE "informix".sp_cob766(a_remesa CHAR(10)) returning smallint,char(255);

define _documento          char(30);
define _con_aviso	       smallint;
define _aviso              char(255);

SET ISOLATION TO DIRTY READ;
--  Set debug file to "sp_cob766.trc";
--  Documentos 


LET _con_aviso = 0;
LET _aviso = "CANCELADA POR FALTA DE PAGO";
Return _con_aviso,_aviso;

Foreach
 Select	doc_remesa
   Into	_documento
   From cobredet
  Where	no_remesa = a_remesa
    and	renglon  <>  0
	and tipo_mov <> 'B'  -- Recibo Anulado

    CALL sp_che127(_documento) RETURNING _con_aviso,_aviso;
	if _con_aviso = 1 then 
		exit foreach;
	end if
End Foreach
Return _con_aviso,_aviso;

END PROCEDURE

  