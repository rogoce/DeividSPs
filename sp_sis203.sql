-- Verificar 1% adicional de comision por conversion de cartera a electronico

-- Creado    : 19/02/2015 - Autor: Armando Moreno.

--DROP PROCEDURE sp_sis203;

CREATE PROCEDURE "informix".sp_sis203(a_no_documento char(20), a_pgo_ext smallint, a_per char(7))
returning decimal(16,2),integer;


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
define _cnt             integer;
define _fecha_cambio    date;
define _cod_formapag    char(3);
define _procesado       smallint;
define _tipo_forma      smallint;
define _periodo_cambio  char(7);
define _comision        decimal(16,2);
define _porc            integer;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro1007.trc";
--trace on;


BEGIN

let _porc = 0;

select count(*)
  into _cnt
  from cobcampl2
 where no_documento = a_no_documento;

if _cnt is null then
	let _cnt = 0;
end if 

if _cnt = 0 then
	return 3,0;
else
	select fecha_cambio,
	       cod_formapag,
		   procesado
	  into _fecha_cambio,
	       _cod_formapag,
		   _procesado
      from cobcampl2
     where no_documento = a_no_documento;

	if _procesado = 1 then
		return 3,0;
    end if
	
	select tipo_forma
	  into _tipo_forma
	  from cobforpa
	 where cod_formapag = _cod_formapag;
	 
	if _tipo_forma = 6 or a_pgo_ext = 2 then	--Pago por Remesa
		let _comision = 2.5;
		let _porc     = 1;
	else										--Ventanilla
		let _comision = 1;
		let _porc     = 1;
	end if 
	
	let _periodo_cambio = sp_sis39(_fecha_cambio);

	if _periodo_cambio = a_per then
		return _comision, _porc;
	elif _periodo_cambio < a_per then
		return 3, 0;
	elif _periodo_cambio > a_per then
		return _comision,0;
    end if	
	 
end if

END
END PROCEDURE
