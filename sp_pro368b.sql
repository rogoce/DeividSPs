-- Procedimiento que carga las coberturas de los prodcutos en el Proceso de Emisiones Electronicas Tecnica de seguros.
-- creado    : 01/09/2014 - Autor: Federico Coronado
-- sis v.2.0 - deivid, S.a.
drop procedure sp_pro368b;
create procedure "informix".sp_pro368b(a_cod_agente char(5), a_num_carga char(10), a_renglon smallint, a_poliza char(10), a_opcion char(1))
returning   integer;   -- _error

define _sql_describe	lvarchar;
define _sql_where		lvarchar;
define _desc_limite1	varchar(50);
define _desc_limite2	varchar(50);
define _error_desc		varchar(50);
define _campo_deducible	char(30);
define _campo_limite1	char(30);
define _campo_limite2	char(30);
define _campo_prima		char(30);
define _cod_cobertura	char(5);
define _cod_producto	char(5);
define _no_unidad		char(5);
define _cod_subramo		char(3);
define _cod_ramo		char(3);
define _prima_neta_emi	dec(16,2);
define _prima_resta		dec(16,2);
define _prima_neta		dec(16,2);
define _prima_vida		dec(16,2);
define _dif_prima		dec(16,2);
define _descuento		dec(16,2);
define _deducible		dec(16,2);
define _recargo			dec(16,2);
define _limite1   		dec(16,2);
define _limite2		   	dec(16,2);
define _prima		   	dec(16,2);
define _cob_requerida	smallint;
define _acepta_desc		smallint;
define _error_isam		smallint;
define _cnt_cober		smallint;
define _cant_iter		smallint;
define _orden			smallint;
define _error			smallint;
define _cont			smallint;
define _fecha_hoy		date;

begin

on exception set _error,_error_isam,_error_desc
 	return _error;         
end exception

set isolation to dirty read;

{create temp table tmp_cober(
prima		dec(16,2),
limite1		dec(16,2),
limite2		dec(16,2),
deducible	dec(16,2)
) with no log;}

let _prima_vida			= 0.00;
let _prima_resta		= 0.00;
let _fecha_hoy 			= current;
let _campo_deducible	= '';
let	_campo_limite1		= '';
let _campo_limite2		= '';
let	_campo_prima		= '';
let _desc_limite1		= '';
let	_desc_limite2		= '';

--set debug file to "sp_pro368b.trc";      
--trace on;


select cod_ramo,
	   cod_subramo
  into _cod_ramo,
	   _cod_subramo
  from emipomae
 where no_poliza	= a_poliza;

if _cod_ramo not in ('019','016') then
	select prima_vida
	  into _prima_vida
	  from prdemielctdet
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and proceso		= a_opcion
	   and renglon		= a_renglon;	
end if

foreach
	select no_unidad,
		   cod_producto,
		   prima
	  into _no_unidad,
	  	   _cod_producto,
		   _prima
	  from emipouni
	 where no_poliza = a_poliza
	 
	if a_poliza = '719607' and _no_unidad = '00001' then
		continue foreach;
	end if

	foreach
		select cod_cobertura,
			   cob_requerida,
			   orden,
			   desc_limite1,	
			   desc_limite2,
			   deducible
		  into _cod_cobertura,
		  	   _cob_requerida,
		  	   _orden,
			   _desc_limite1,	
			   _desc_limite2,
			   _deducible
		  from prdcobpd
		 where cod_producto = _cod_producto
		   and cob_default = 1
		   order by orden
					
	select acepta_desc
	  into _acepta_desc
	  from prdcobpd
	 where cod_producto = _cod_producto
	   and cod_cobertura = _cod_cobertura;

			select first 1 rango_monto1,
				   rango_monto2
			  into _limite1,
				   _limite2
			  from prdtasec 
			 where cod_producto		= _cod_producto
			   and cod_cobertura	= _cod_cobertura;

			if _desc_limite1 is null then
				let _desc_limite1 = '';
			end if

			if _desc_limite2 is null then
				let _desc_limite2 = '';
			end if

			if _acepta_desc = 1 then
				CALL sp_proe21(a_poliza, _no_unidad, _prima) RETURNING _descuento;

				if _descuento > 0 then
					let _prima_resta = _prima - _descuento;
				end if
			else
				let _descuento = 0.00;
				let _prima_resta = _prima;
			end if

			CALL sp_proe22(a_poliza, _no_unidad, _prima_resta) RETURNING _recargo;

			let _prima_neta = _prima + _recargo - _descuento;
			
			if _deducible is null then
				let _deducible	= 0.00;
			end if 
			
			if _limite1 is null then
				let _limite1	= 0.00;
			end if
			
			if _limite2 is null then
				let _limite2	= 0.00;
			end if
			   
			insert into emipocob(
					no_poliza,		   	--(a_poliza,
					no_unidad,		   	--_no_unidad,
					cod_cobertura,	   	--_cod_cobertura,
					orden,			   	--_orden,
					tarifa,			   	--0,
					deducible,		   	--_deducible,
					limite_1,		   	--_limite1,
					limite_2,		   	--_limite2,
					prima,			   	--_prima,
					descuento,		   	--0,
					recargo,		   	--0,
					prima_neta,		   	--_prima,
					date_added,		   	--_fecha_hoy,
					date_changed,	   	--_fecha_hoy,
					factor_vigencia,   	--1
					desc_limite1,	   	--_desc_limite1,
					desc_limite2,	   	--_desc_limite2,
					prima_vida,		   	--_prima_vida,
					prima_vida_orig,	--_prima_vida
					prima_anual)
			values	(a_poliza,			--no_poliza,		
					_no_unidad,			--no_unidad,		
					_cod_cobertura,		--cod_cobertura,	
					_orden,				--orden,			
					0,					--tarifa,			
					_deducible,			--deducible,		
					_limite1,			--limite_1,		
					_limite2,			--limite_2,		
					_prima,				--prima,			
					_descuento,			--descuento,		
					0,					--recargo,		
					_prima_neta,		--prima_neta,		
					_fecha_hoy,			--date_added,		
					_fecha_hoy,			--date_changed,	
					1,					--factor_vigencia
					_desc_limite1,		--desc_limite1,	
					_desc_limite2,		--desc_limite2,	
					_prima_vida,		--prima_vida,		
					_prima_vida,		--prima_vida_orig
					_prima
					);
		let _prima = 0.00;
	end foreach
	let _prima_neta_emi = 0.00;
	let _prima_neta = 0.00;
	let _dif_prima = 0.00;
	let _cant_iter = 0;
	let _cont = 0;
	
	select sum(prima_neta)
	  into _prima_neta
	  from emipocob
	 where no_poliza = a_poliza
	   and no_unidad = _no_unidad;
	   
	select sum(prima_neta)
	  into _prima_neta_emi
	  from emipomae
	 where no_poliza = a_poliza;
	 
	let _dif_prima	= (_prima_neta - _prima_neta_emi);
	
	if _dif_prima < 1.00 then
		let _cant_iter	= abs(_dif_prima)	* 100;
		
		if _cant_iter > 0 then
			foreach
				select cod_cobertura
				  into _cod_cobertura
				  from emipocob
				 where no_poliza = a_poliza
				   and prima_neta > 0
				   and descuento > 0
				
				if _dif_prima < 0.00 then
					update emipocob
					   set prima_neta = prima_neta + 0.01,
						   descuento = descuento + 0.01
					 where no_poliza = a_poliza
					   and no_unidad = _no_unidad
					   and cod_cobertura = _cod_cobertura;
				elif _dif_prima > 0.00 then
					update emipocob
					   set prima_neta = prima_neta - 0.01,
						   descuento = prima_neta - 0.01
					 where no_poliza = a_poliza
					   and no_unidad = _no_unidad
					   and cod_cobertura = _cod_cobertura;
				end if
				let _cont = _cont + 1;
				if _cont >= _cant_iter then
					exit foreach;
				end if
			end foreach
		end if
	end if
end foreach
--drop table tmp_cober;
end
end procedure