-- Procedimiento que Busca el banco y chequera para clientes Banisi

-- Creado    : 22/05/2023 - Autor: Amado Perez.



DROP PROCEDURE sp_rec321;

CREATE PROCEDURE "informix".sp_rec321(a_no_tranrec CHAR(10), a_tipo_requis CHAR(1), a_cod_banco CHAR(3), a_cod_chequera CHAR(3))
returning smallint, char(1), char(3), char(3);

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
define _finiquito_firmado smallint;

SET ISOLATION TO DIRTY READ;

--	set debug file to "sp_rec321.trc";
--	trace on;

let _tipo_requis  = a_tipo_requis;
let _cnt_conc = 0;
let _finiquito_firmado = 0;
let _cod_banco = a_cod_banco;
let _cod_chequera = a_cod_chequera;

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
--    and cod_concepto in ('026','044');  

	
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
			let _tipo_requis  = 'A';
			let _finiquito_firmado  = 1;
			if _cod_ramo in ('016','019') then
				let _cod_chequera = '006';
			end if				
		end if	
	end if
 end if
  

Return _finiquito_firmado, _tipo_requis, _cod_banco, _cod_chequera;

END PROCEDURE
