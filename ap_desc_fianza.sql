-- Genera Cheque ACH
-- Creado    : 08/06/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che123('2',0)

DROP PROCEDURE ap_desc_fianza;
CREATE PROCEDURE ap_desc_fianza() 
RETURNING  char(5) as codproducto,				--Salud
		   varchar(50) as nombreproducto,
		   char(3) as codramo,
		   varchar(50) as nombreramo,
		   char(3) as codsubramo,
		   varchar(50) as nombresubramo,
		   char(10) as polizainterna,
		   char(20) as poliza,
		   char(5) as unidad,
		   date as viginipoliza,
		   date as vigfinpoliza,
		   date as viginiunidad,
		   date as vigifinunidad,
		   REFERENCES TEXT as descripcion;

DEFINE 	_no_poliza		    char(10);
DEFINE 	_no_unidad			char(5);
DEFINE 	_opcion				char(1);
DEFINE 	_no_documento		char(20);
DEFINE  _error              integer;
DEFINE  _notrx              integer;
DEFINE  _error_desc         varchar(50);
DEFINE  _no_pagos           smallint;

DEFINE codproducto		char(5);
DEFINE nombreproducto   varchar(50);
DEFINE codramo			char(3);
DEFINE nombreramo		varchar(50);
DEFINE codsubramo		char(3);
DEFINE nombresubramo 	varchar(50);
DEFINE polizainterna    char(10);
DEFINE poliza			char(20);
DEFINE unidad			char(5);
DEFINE viginipoliza		date;
DEFINE vigfinpoliza		date;
DEFINE viginiunidad		date;
DEFINE vigifinunidad	date;
DEFINE lblb_descripcion REFERENCES TEXT;

SET ISOLATION TO DIRTY READ;
--  set debug file to "ap_desc_fianza.trc";	
--  trace on;

--begin work;

begin
on exception set _error
--    rollback work;
	return _error, "Error al Cambiar Tarifas...", null, null, null, null, null, null, null, null, null, null, null, null;
end exception


foreach 
	select p.cod_producto as codproducto,
	p.nombre as nombreproducto,
	p.cod_ramo as codramo,
	r.nombre   as nombreramo,
	p.cod_subramo as codsubramo,
	sr.nombre as nombresubramo,
	nvl(e.no_poliza,99999999) as polizainterna,
	e.no_documento as poliza,
	nvl(u.no_unidad,'99999') as unidad,
	e.vigencia_inic as viginipoliza,
	e.vigencia_final as vigfinpoliza,
	u.vigencia_inic as viginiunidad,
	u.vigencia_final as vigifinunidad
	into codproducto,
	     nombreproducto,
		 codramo,
		 nombreramo,
		 codsubramo,
		 nombresubramo,
		 polizainterna,
		 poliza,
		 unidad,
		 viginipoliza,
		 vigfinpoliza,
		 viginiunidad,
		 vigifinunidad
	from prdprod p
	join emipouni u on u.cod_producto = p.cod_producto
	join emipomae e on e.no_poliza = u.no_poliza
	join prdramo r on r.cod_ramo = p.cod_ramo
	join prdsubra sr on sr.cod_ramo = p.cod_ramo and sr.cod_subramo = p.cod_subramo
	where p.cod_ramo in ('008') --and e.no_documento = '0802-01718-01'
{	select p.cod_producto,
		p.nombre,
		p.cod_ramo,
		r.nombre,
		p.cod_subramo,
		sr.nombre,
		nvl(e.no_poliza,99999999),
		e.no_documento,
		nvl(u.no_unidad,'99999'),
		e.vigencia_inic,
		e.vigencia_final,
		u.vigencia_inic,
		u.vigencia_final
	into codproducto,
	     nombreproducto,
		 codramo,
		 nombreramo,
		 codsubramo,
		 nombresubramo,
		 polizainterna,
		 poliza,
		 unidad,
		 viginipoliza,
		 vigfinpoliza,
		 viginiunidad,
		 vigifinunidad
	from prdprod p
	join emipouni u on u.cod_producto = p.cod_producto
	join emipomae e on e.no_poliza = u.no_poliza
	join prdramo r on r.cod_ramo = p.cod_ramo
	join prdsubra sr on sr.cod_ramo = p.cod_ramo and sr.cod_subramo = p.cod_subramo
	where e.estatus_poliza = 1
	--and p.activo = 1
	and p.cod_ramo in ('008')
}	  
	let lblb_descripcion = null;  

	let lblb_descripcion = sp_blob_emipode2(polizainterna, unidad); 
		
	--let lblb_descripcion = REPLACE(lblb_descripcion, "\n", "");
	--let lblb_descripcion = REPLACE(lblb_descripcion, "\r\n", "");
	
	return 	codproducto,
			nombreproducto,
			codramo,
			nombreramo,
			codsubramo,
			nombresubramo,
			polizainterna,
			poliza,
			unidad,
			viginipoliza,
			vigfinpoliza,
			viginiunidad,
			vigifinunidad,
			lblb_descripcion with resume;
end foreach
end

--commit work;

END PROCEDURE	  