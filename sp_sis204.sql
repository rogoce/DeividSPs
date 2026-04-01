-- Verificar 1% adicional de comision por conversion de cartera a electronico

-- Creado    : 19/02/2015 - Autor: Armando Moreno.

DROP PROCEDURE sp_sis204;

CREATE PROCEDURE "informix".sp_sis204(a_no_documento char(20),a_no_cambio char(10),a_cod_formapag char(3))
returning integer;


define _nombre			varchar(100);
define _cod_contratante char(10);
define _cod_aseg        char(10);
define _no_documento    char(20);
define _vigencia_inic   date;
define _fecha_actual    char(100);
define _fecha           date;
define _vigencia_inic_c char(100);
define _nombre_aseg     varchar(100);
define _prima_bruta     decimal(16,2);
define _valor,_cnt      smallint;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro1007.trc";
--trace on;

let _valor = 0;
BEGIN

select count(*)
  into _cnt
  from cobcampl2
 where no_documento = a_no_documento;
 
 if _cnt is null then
	let _cnt = 0;
 end if
		 
if _cnt = 0 then 
	insert into cobcampl2
	select *,0 from cobcampl
	 where no_documento = a_no_documento
	   and no_cambio    = a_no_cambio;

	update cobcampl2
       set cod_formapag = a_cod_formapag
	 where no_documento = a_no_documento
	   and no_cambio    = a_no_cambio;
	   
else
	let _valor = 1;
end if

return _valor;
END
END PROCEDURE
