-- Recibos de comision de tecnica grupo suctracs

-- Creado    : 16/04/2013 - Autor: Armando Moreno.

DROP PROCEDURE sp_sis183;

CREATE PROCEDURE "informix".sp_sis183()
returning char(20),char(10),dec(16,2),dec(16,2),date,char(6),char(8);

define _comision,_monto_recibo	 dec(16,2);
define _no_poliza    char(10);
define _fecha        date;
define _no_documento char(20);
define _cnt          smallint;
define _no_recibo    char(10);
define _no_requis    char(10);
define _tipo         char(6);
define _tipo_requis  char(1);
define _tipo_pago    smallint;
define _pag          char(8);
define _no_remesa    char(10);
define _renglon      integer;


--SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_sis180.trc";
--trace on;

SET LOCK MODE TO WAIT;


let _comision = 0;
let _monto_recibo = 0;

BEGIN

foreach

	select no_poliza,fecha,comision,no_documento,no_recibo,monto,no_requis
	  into _no_poliza,_fecha,_comision,_no_documento,_no_recibo,_monto_recibo,_no_requis
	  from chqcomis
	 where cod_agente = '00180'	   --Tecnica de seguros
	   and fecha >= '01/04/2013'
	   and fecha <= '28/05/2013'
	order by fecha

	select count(*)
	  into _cnt
	  from emipomae
	 where no_poliza = _no_poliza
	   and cod_grupo = "01016";		--Grupo Sunctracs

    select tipo_requis
	  into _tipo_requis
	  from chqchmae
	 where no_requis = _no_requis;

   foreach
    select no_remesa,
	       renglon
	  into _no_remesa,
	       _renglon
	  from cobredet
	 where no_poliza = _no_poliza
	   and no_recibo = _no_recibo 
	exit foreach;
   end foreach


   select tipo_pago
     into _tipo_pago
	 from cobrepag
	where no_remesa = _no_remesa
	  and renglon   = _renglon;

    if _tipo_pago = 1 then
		let _pag = 'EFECTIVO';
	elif _tipo_pago = 2 then
		let _pag = 'CHEQUE';
	elif _tipo_pago = 3 then
		let _pag = 'CLAVE';
	elif _tipo_pago = 4 then
		let _pag = 'TC';

	end if


    if _tipo_requis = 'A' then
	   let _tipo = 'ACH';
	else
	   let _tipo = 'CHEQUE';
	end if

	if _cnt > 0 then
		 return _no_documento,_no_recibo,_monto_recibo,_comision,_fecha,_tipo,_pag with resume;
	else
		
	end if

end foreach

END
END PROCEDURE
