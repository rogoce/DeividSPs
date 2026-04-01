-- Procedimiento que Busca el banco y chequera para clientes Banisi

-- Creado    : 09/03/2022 - Autor: Amado Perez.



DROP PROCEDURE sp_rec318;

CREATE PROCEDURE "informix".sp_rec318(a_no_tranrec CHAR(10), a_banco CHAR(3), a_chequera CHAR(3), a_tipo_requis CHAR(1))
returning char(3),char(3),char(1);

define _tipo_pago		smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _tipo_requis     char(1);
define _no_reclamo      char(10);
define _cod_cliente     char(10);
define _cod_tipopago    char(3);
define _cnt_conc        smallint;
define _no_poliza       char(10);
define _cod_ramo        char(3);

SET ISOLATION TO DIRTY READ;

let _cod_banco    = a_banco;
let _cod_chequera = a_chequera;
let _tipo_requis  = a_tipo_requis;
let _cnt_conc = 0;

select no_reclamo,
       cod_cliente,
       cod_tipopago 
  into _no_reclamo,
       _cod_cliente,	   
       _cod_tipopago  
  from rectrmae
 where no_tranrec = a_no_tranrec;
 
 select count(*)
   into _cnt_conc
   from rectrcon
  where no_tranrec = a_no_tranrec
    and cod_concepto in ('026','044','015','016','073','074','075');  -- SD#9801:JEPEREZ anexar 015,016,073,074 y 075 26/03/2024
    --and cod_concepto in ('026','044');  
	
 if _cnt_conc is null then
	let _cnt_conc = 0;
 end if	
 
 select no_poliza 
   into _no_poliza
   from recrcmae
  where no_reclamo = _no_reclamo;  
 
 select cod_ramo
   into _cod_ramo
   from emipomae
  where no_poliza = _no_poliza;

 if _cod_ramo in ('002','023','016','019') then
	if _cod_tipopago = '003' and _cnt_conc > 0 then
		if _cod_cliente = '417605' then -- BANISI, S.A.
			let _cod_banco = '295';
			let _cod_chequera = '045';
			let _tipo_requis  = 'A';
		end if	
	end if
 end if
  

Return _cod_banco,_cod_chequera,_tipo_requis;

END PROCEDURE
