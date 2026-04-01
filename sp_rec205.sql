-- Procedimiento que Busca la Información de las tablas recparte y recpre
-- Creado    : 11/06/2013 - Autor: Román Gordón

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

drop procedure sp_rec205;		

create procedure "informix".sp_rec205()

returning	char(5),		--_no_parte,
			varchar(50),	--_desc_parte,
			varchar(50),	--_nom_loc_pieza,
			smallint,		--_se_repara,
			smallint,		--_se_cambia,
			smallint,		--_se_pinta,
			smallint,		--_se_pintarep,
			varchar(50),	--_nom_trabajo,
			dec(16,2),		--_precio_chico,
			dec(16,2),		--_precio_mediano,
			dec(16,2);		--_precio_grande

define _nom_trabajo		varchar(50);
define _desc_parte		varchar(50);
define _nom_loc_pieza	varchar(50);
define _no_parte		char(5);
define _loc_pieza		char(2);
define _trabajo			char(1);
define _precio_mediano	dec(16,2);
define _precio_grande	dec(16,2);
define _precio_chico	dec(16,2);
define _se_pintarep		smallint;
define _se_repara		smallint;
define _se_cambia		smallint;
define _se_pinta		smallint;

set isolation to dirty read;
--set debug file to "sp_rec205.trc";
--trace on;

foreach
	select no_parte,
		   desc_parte,
		   loc_pieza,
		   se_repara,
		   se_cambia,
		   se_pinta,
		   se_pintarep
	  into _no_parte,
		   _desc_parte,
		   _loc_pieza,
		   _se_repara,
		   _se_cambia,
		   _se_pinta,
		   _se_pintarep
	  from recparte
	
	if _loc_pieza = '01' then
		let _nom_loc_pieza = 'Frontal';
	elif _loc_pieza = '02' then
		let _nom_loc_pieza = 'Trasera';
	elif _loc_pieza = '03' then
		let _nom_loc_pieza = 'Capota';
	elif _loc_pieza = '04' then
		let _nom_loc_pieza = 'Lateral Derecho';
	elif _loc_pieza = '05' then
		let _nom_loc_pieza = 'Lateral Izquierdo';
	elif _loc_pieza = '06' then
		let _nom_loc_pieza = 'Parabrisas';
	elif _loc_pieza = '07' then
		let _nom_loc_pieza = 'Interior del Auto';
	elif _loc_pieza = '09' then
		let _nom_loc_pieza = 'Debajo del Auto';
	elif _loc_pieza = '09' then
		let _nom_loc_pieza = '';
	elif _loc_pieza = '10' then
		let _nom_loc_pieza = 'Motor';
	end if
	
	foreach
		select trabajo,
			   precio_chico,
			   precio_mediano,
			   precio_grande
		  into _trabajo,
			   _precio_chico,
			   _precio_mediano,
			   _precio_grande
		  from recprec
		 where no_parte = _no_parte
		 
		if _trabajo = '1' then
			let _nom_trabajo = 'Reparar';
		elif _trabajo = '2' then
			let _nom_trabajo = 'Cambiar';
		elif _trabajo = '3' then
			let _nom_trabajo = 'Pintar';
		elif _trabajo = '4' then
			let _nom_trabajo = 'Pintar/Reparar';
		end if
		
		return	_no_parte,
				_desc_parte,
				_nom_loc_pieza,
				_se_repara,
				_se_cambia,
				_se_pinta,
				_se_pintarep,
				_nom_trabajo,
				_precio_chico,
				_precio_mediano,
				_precio_grande
				with resume;
	end foreach
end foreach
end procedure