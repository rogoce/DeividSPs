-- Procedimiento que carga las coberturas de los prodcutos en el Proceso de Emisiones Electronicas.
--
-- creado    : 28/08/2012 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.

drop procedure sp_pro368;
create procedure "informix".sp_pro368(a_cod_agente char(5), a_num_carga char(10), a_renglon smallint, a_poliza char(10), a_opcion char(1))
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
define _cod_producto,_cod_grupo	char(5);
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
let _error = 0;

--set debug file to "sp_pro368.trc";      
--trace on;


select cod_ramo,
	   cod_subramo,
	   cod_grupo	   
  into _cod_ramo,
	   _cod_subramo,
	   _cod_grupo
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
		   cod_producto
	  into _no_unidad,
	  	   _cod_producto
	  from emipouni
	 where no_poliza = a_poliza
	 
	if a_poliza = '719607' and _no_unidad = '00001' then
		continue foreach;
	end if
--
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

		select count(*)
		  into _cnt_cober
		  from equicober
		 where cod_agente			= a_cod_agente
		   and cod_ramo_ancon		= _cod_ramo
		   and cod_subramo_ancon	= _cod_subramo
		   and cod_cobertura_ancon	= _cod_cobertura
		   and campo_prima is not null;

		if _cnt_cober > 0 then		
			select campo_prima,
				   campo_limite1,
				   campo_limite2,
				   campo_deducible
			  into _campo_prima,
			  	   _campo_limite1,
			  	   _campo_limite2,
				   _campo_deducible
			  from equicober
			 where cod_agente			= a_cod_agente		 
			   and cod_ramo_ancon		= _cod_ramo
			   and cod_subramo_ancon	= _cod_subramo
			   and cod_cobertura_ancon	= _cod_cobertura;

			
			let _sql_where		= "cod_agente = " || a_cod_agente || "and num_carga = " || a_num_carga || " and proceso = '" || a_opcion ||"' and renglon = " || trim(cast(a_renglon as char(3)));
			let _sql_describe	= "select " || trim(_campo_prima);
			{if _campo_deducible = '' or _campo_deducible is null then
				let _deducible = 0;
				let _sql_describe	= "select " || trim(_campo_prima) || "," || trim(_campo_limite1) || "," || trim(_campo_limite2) || " from prdemielctdet where " || _sql_where;
			else
				let _sql_describe	= "select " || trim(_campo_prima) || "," || trim(_campo_limite1) || "," || trim(_campo_limite2) || "," || trim(_campo_deducible) || " from prdemielctdet where " || _sql_where;
			end if}
			
			if _campo_limite1 is not null then
				let _sql_describe = trim(_sql_describe) || ',' || trim(_campo_limite1);
			end if

			if _campo_limite2 is not null then
				let _sql_describe = trim(_sql_describe) || ',' || trim(_campo_limite2);
			end if

			if _campo_deducible is not null then
				let _sql_describe = trim(_sql_describe) || ',' ||trim(_campo_deducible);
			end if

			let _sql_describe = trim(_sql_describe) || " from prdemielctdet where " || _sql_where;

			prepare equisql from _sql_describe;	
			declare equicur cursor for equisql;
			open equicur;
			while (1 = 1)
				if (_campo_limite1	= '' or _campo_limite1 is null)
				and (_campo_deducible = '' or _campo_deducible is null) then
					fetch equicur into	_prima;
					
					let _deducible	= 0.00;
					let _limite1	= 0.00;
					let _limite2	= 0.00;

				elif (_campo_deducible = '' or _campo_deducible is null) then
					fetch equicur into	_prima,	
										_limite1,
										_limite2;
					let _deducible = 0.00;					
				else
					fetch equicur into	_prima,	
										_limite1,
										_limite2,
										_deducible;
				end if

				if (sqlcode = 100) then
					exit;
				end if

				if (sqlcode != 100) then
					
					if (_campo_deducible = '' or _campo_deducible is null) then
						foreach
							select deducible
							  into _deducible
							  from prdcobrd
							 where cod_producto = _cod_producto
							   and cod_cobertura = _cod_cobertura
							   and rango1 = _limite1
							   and rango2 = _limite2
							if _deducible <> 0 then
								exit foreach;
							end if
						end foreach
					end if
					
					select acepta_desc
					  into _acepta_desc
					  from prdcobpd
					 where cod_producto = _cod_producto
					   and cod_cobertura = _cod_cobertura;

					if _desc_limite1 is null then
						let _desc_limite1 = '';
					end if

					if _desc_limite2 is null then
						let _desc_limite2 = '';
					end if
					if _cod_grupo = '77850' then
						let _acepta_desc = 0;
						let _recargo     = 0;
						let _descuento   = 0;
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
					if _cod_grupo = '77850' then
					else
						CALL sp_proe22(a_poliza, _no_unidad, _prima_resta) RETURNING _recargo;
					end if	

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
				else
					exit;
				end if
			end while
			close equicur;	
			free equicur;
			free equisql;
		else		
			select rango_monto1,
				   rango_monto2,
				   valor
			  into _limite1,
				   _limite2,
				   _prima
			  from prdtasec 
			 where cod_producto		= _cod_producto
			   and cod_cobertura	= _cod_cobertura;
			
			if _deducible is null then
				let _deducible	= 0.00;
			end if 
			
			if _limite1 is null then
				let _limite1	= 0.00;
			end if
			
			if _limite2 is null then
				let _limite2	= 0.00;
			end if
			
			if _prima is null and _cod_cobertura = '00907' then
				select valor_tar_unica
				  into _prima
				  from prdcobpd
				 where cod_producto  = '01953'
				   and cod_cobertura = _cod_cobertura;
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
					0.00,			--descuento,		
					0,					--recargo,		
					_prima,				--prima_neta,		
					_fecha_hoy,			--date_added,		
					_fecha_hoy,			--date_changed,	
					1,					--factor_vigencia
					_desc_limite1,		--desc_limite1,	
					_desc_limite2,		--desc_limite2,	
					0.00,		--prima_vida,		
					0.00,		--prima_vida_orig
					0.00
					);	
		end if
	end foreach
	if _cod_grupo = '77850' then
	else
		call sp_proe01(a_poliza,_no_unidad,'001') returning _error;
	end if

	if _error <> 0 then
		return _error;--, 'Ha Ocurrido un error al calcular el descuento por cobertura. Por Favor Verifique.';
	end if
		
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