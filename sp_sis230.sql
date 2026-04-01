-- Procedimiento que Ajusta la información de prima en la estructura de emision tomando en cuenta la información que esta en endosos
-- Creado    : 07/11/2016 - Autor: Román Gordon

drop procedure sp_sis230;
create procedure sp_sis230()--, a_no_unidad char(5))
returning	varchar(50)		as campana,
			char(20)		as Poliza,
			date			as Vigencia_inic,
			date			as Vigencia_final,
			date			as Fecha_primer_pago,
			dec(16,2)		as Prima,
			smallint		as Dias_Venc,
			char(1)			as Nueva_renov,
			varchar(50)		as Grupo;

define _mensaje				varchar(250);
define _nom_campana			varchar(50);
define _nom_grupo			varchar(50);
define _no_documento		char(20);
define _cod_cliente			char(10);
define _cod_campana			char(10);
define _no_poliza			char(10);
define _cod_grupo			char(5);
define _nueva_renov			char(1);
define _prima_bruta			dec(16,2);
define _dias_transcurridos	smallint;
define _estatus_poliza		smallint;
define _cnt_cliente			smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_primer_pago	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_hoy			date;

set isolation to dirty read;

--set debug file to "sp_sis230.trc";
--trace on;

begin
on exception set _error,_error_isam,_mensaje
	--rollback work;
 	return _mensaje,'',null,null,null,0.00,_error,'','';
end exception

let _fecha_hoy = current;

foreach
	select p.cod_campana,
		   p.cod_cliente,
		   p.no_documento,
		   c.nombre
	  into _cod_campana,
		   _cod_cliente,
		   _no_documento,
		   _nom_campana
	  from cascampana c, caspoliza p
	 where c.cod_campana = p.cod_campana
	   and c.tipo_campana = 3

	--call sp_pro544(_no_documento) returning _error,_mensaje;
	call sp_sis21(_no_documento) returning _no_poliza;
	
	select vigencia_inic,
		   vigencia_final,
		   estatus_poliza,
		   nueva_renov,
		   fecha_primer_pago,
		   _fecha_hoy - fecha_primer_pago,
		   cod_grupo,
		   prima_bruta
	  into _vigencia_inic,
		   _vigencia_final,
		   _estatus_poliza,
		   _nueva_renov,
		   _fecha_primer_pago,
		   _dias_transcurridos,
		   _cod_grupo,
		   _prima_bruta
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza <> 1 then
		continue foreach;
	end if

	select nombre
	  into _nom_grupo
	  from cligrupo
	 where cod_grupo = _cod_grupo;

	return	_nom_campana,
			_no_documento,
			_vigencia_inic,
			_vigencia_final,
			_fecha_primer_pago,
			_prima_bruta,
			_dias_transcurridos,
			_nueva_renov,
			_nom_grupo	with resume;
end foreach

end
end procedure;