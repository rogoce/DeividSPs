-- Procedimiento que carga las coberturas de los prodcutos en el Proceso de Emisiones Electronicas.
--
-- creado    : 28/08/2012 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.

drop procedure sp_pro368a;
create procedure "informix".sp_pro368a(a_no_poliza char(10),a_no_unidad char(5),a_cod_agente char(5))
returning   integer,
			char(100);   -- _error

define _deducible_char	varchar(50);
define _deduc_char		varchar(50);
define _error_desc		char(100);
define _cod_cobertura	char(5);
define _cod_subramo		char(3);
define _cod_ramo		char(3);
define _char			char(1);
define _deducible		dec(16,2);
define _limite1   		dec(16,2);
define _limite2		   	dec(16,2);
define _prima		   	dec(16,2);
define _error_isam		smallint;
define _tipo_cober		smallint;
define _len_valor		smallint;
define _cant_char		smallint;
define _error			smallint;

begin

on exception set _error,_error_isam,_error_desc
	drop table tmp_cober2; 
 	return _error,_error_desc;
end exception

set isolation to dirty read;

drop table if exists tmp_cober2;

create temp table tmp_cober2(
prima		dec(16,2),
limite1		dec(16,2),
limite2		dec(16,2),
deducible	dec(16,2),
tipo_cober	smallint
) with no log;

--set debug file to "sp_pro368a.trc";      
--trace on;

let _deducible_char = '';
let _cod_cobertura	= '';
let _prima			= 0.00;
let _limite1  		= 0.00;
let _limite2  		= 0.00;
let _deducible		= 0.00;

select cod_ramo,
	   cod_subramo	
  into _cod_ramo,
	   _cod_subramo	
  from emipomae
 where no_poliza	= a_no_poliza;

foreach
	select cod_cobertura,  -- Se busca la informacion de endedmae endoso 0, ID de la solicitud	# 6580 Amado 18-05-2023
		   prima,
		   limite_1,
		   limite_2,
		   deducible
	  into _cod_cobertura,
		   _prima,
		   _limite1,
		   _limite2,
		   _deducible_char	
	  from endedcob
	 where no_poliza = a_no_poliza
	   and no_unidad = a_no_unidad
	   and no_endoso = '00000'


{	select cod_cobertura,
		   prima,
		   limite_1,
		   limite_2,
		   deducible
	  into _cod_cobertura,
		   _prima,
		   _limite1,
		   _limite2,
		   _deducible_char	
	  from emipocob
	 where no_poliza = a_no_poliza
	   and no_unidad = a_no_unidad
}
	select tipo_cober
	  into _tipo_cober
	  from equicober
	 where cod_agente			= a_cod_agente
	   and cod_ramo_ancon		= _cod_ramo
	   and cod_subramo_ancon	= _cod_subramo
	   and cod_cobertura_ancon	= _cod_cobertura;

	begin
		on exception in(-1213)
			let _len_valor	= length(_deducible_char);
			let _deduc_char = '';
			
			for _cant_char	= 1 to _len_valor 
				let _char	= _deducible_char[1];
				let _deducible_char	= _deducible_char[2,50];

				if _char in ('.','0','1','2','3','4','5','6','7','8','9','-') then
					let _deduc_char = _deduc_char || _char;
				end if
			end for
			let _deducible = _deduc_char;
		end exception
		
		let _deducible = cast(_deducible_char as dec(16,2));
	end

	if _tipo_cober > 0 then
		insert into tmp_cober2
	   			(prima,
	   			limite1,
	   			limite2,
	   			deducible,
	   			tipo_cober
	   			)
	   	values	(_prima,
	   			_limite1,
				_limite2,
				_deducible,
				_tipo_cober
				);
	end if
	
	let _tipo_cober = 0;
	let _deducible	= 0.00;
	let _prima		= 0.00;
	let _limite1	= 0.00;
	let _limite2	= 0.00;
end foreach
--drop table tmp_cober2;
end
return 0,'Insercion Exitosa';
end procedure
