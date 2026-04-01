--------------------------------------------
---  REPORTE ESPECIAL QUE SUMINISTRA INF. DE SINIESTROS PARA RAMO SALUD
---  Román Gordón	12/10/2015
--------------------------------------------

drop procedure sp_sis218;
create procedure sp_sis218(a_periodo1 char(7), a_periodo2 char(7))
returning	varchar(100)	as Asegurado,
			smallint		as Serie,
			char(10)		as CodDiagnostico,
			varchar(255)	as Diagnostico,
			char(18)		as Reclamo,
			dec(16,2)		as Total_Pagado,
			char(20)		as Poliza,
			date			as Vigencia_Inicial,
			date			as Vigencia_Final,
			date			as Fecha_Nacimiento;

begin

define _filtros				varchar(255);
define _nom_icd				varchar(255);
define _nom_cliente			varchar(100);
define _cedula				varchar(30);
define _no_documento		char(20);
define _numrecla			char(18);
define _cod_contratante		char(10);
define _cod_reclamante		char(10);
define _no_reclamo			char(10);
define _no_poliza			char(10);
define _cod_icd				char(10);
define _pagado_total		dec(16,2);
define _serie				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_ani			date;
define _vig_ini				date;
define _vig_fin				date;

on exception set _error, _error_isam, _filtros
	if _no_documento is null then
		let _no_documento = '';
	end if
	
	drop table if exists tmp_sinis;
 	return _filtros,
			_error,
			_no_reclamo,
			'',
			'',
			_error_isam,
			_no_documento,
			'01/01/1900',
			'01/01/1900',
			'01/01/1900';
end exception

set isolation to dirty read; 

let _filtros = sp_rec01("001","001",a_periodo1,a_periodo2,"*","*","018;","*","*","*","*","*");

foreach with hold
	select pagado_total,
		   no_reclamo
	  into _pagado_total,
		   _no_reclamo
	  from tmp_sinis
	 where seleccionado = 1

	begin work;

	select no_poliza,
		   numrecla,
		   cod_icd,
		   cod_reclamante
	  into _no_poliza,
		   _numrecla,
		   _cod_icd,
		   _cod_reclamante
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select nombre
	  into _nom_icd
	  from recicd
	 where cod_icd = _cod_icd;

	select no_documento,
		   vigencia_inic,
		   vigencia_final,
		   cod_contratante,
		   serie
	  into _no_documento,
		   _vig_ini,
		   _vig_fin,
		   _cod_contratante,
		   _serie
	  from emipomae
	 where no_poliza = _no_poliza;

	let _cedula    = null;
	let _fecha_ani = null;

	select nombre,
		   cedula,
		   fecha_aniversario
	  into _nom_cliente,
		   _cedula,
		   _fecha_ani
	  from cliclien
	 where cod_cliente = _cod_reclamante;

	return	_nom_cliente,
			_serie,
			_cod_icd,
			_nom_icd,
			_numrecla,
			_pagado_total,
			_no_documento,
			_vig_ini,
			_vig_fin,
			_fecha_ani with resume;

	commit work;
end foreach

drop table if exists tmp_sinis;
end
end procedure;