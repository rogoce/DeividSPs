-- Procedimiento que Realiza la insercion a la tabla emiprede pre exist. del dependiente

-- Creado    : 21/01/2011 - Autor: Armando Moreno M.

drop procedure sp_sis143;

create procedure sp_sis143(
a_no_poliza char(10),
a_no_unidad char(5),
a_cod_depen char(10),
a_excl1 char(5),
a_excl2 char(5),
a_excl3 char(5),
a_tiempo1 smallint,
a_tiempo2 smallint,
a_tiempo3 smallint,
a_usuario_eval char(8),
a_vig_ini date,
a_excl4 char(5),
a_excl5 char(5),
a_tiempo4 smallint,
a_tiempo5 smallint
)
RETURNING INTEGER;

--}

DEFINE li_dia		   SMALLINT;
DEFINE li_mes		   SMALLINT;
DEFINE li_ano		   SMALLINT;
DEFINE _fecha_excl     DATE;
DEFINE v_fecha_r       DATE;
DEFINE _error          smallint; 


--SET DEBUG FILE TO "sp_sis143.trc"; 
--trace on;

SET LOCK MODE TO WAIT;

BEGIN

ON EXCEPTION SET _error
  RETURN _error;
END EXCEPTION

LET v_fecha_r = current;

let li_mes = month(a_vig_ini);
let li_dia = day(a_vig_ini);
let li_ano = year(a_vig_ini);

if li_dia = 31 then
	let li_dia = 30;
end if

if a_tiempo1 = 1 then 		--Permanente no lleva fecha
	let _fecha_excl = null;
elif a_tiempo1 = 2 then		--Un ano de exclusion
	let li_ano      = year(a_vig_ini) + 1;
    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
elif a_tiempo1 = 3 then		--Seis meses de exclusion
	let li_mes = month(a_vig_ini) + 6;
	if li_mes > 12 then
		let li_mes      = li_mes - 12;
		let li_ano      = year(a_vig_ini) + 1;
	end if
	    let _fecha_excl = MDY(li_mes, li_dia, li_ano); 
end if

if a_excl1 is not null or a_excl1 <> "" then --exclusion1

	insert into emiprede(
		   no_poliza,
		   no_unidad,
		   cod_cliente,
		   cod_procedimiento,
		   fecha,
		   user_added,
		   date_added
		   )	
	       values (
	        a_no_poliza,
	        a_no_unidad,
	        a_cod_depen,
	        a_excl1,       		
			_fecha_excl,
			a_usuario_eval,
			v_fecha_r
			);


end if

if a_tiempo2 = 1 then 		--Permanente no lleva fecha
	let _fecha_excl = null;
elif a_tiempo2 = 2 then		--Un ano de exclusion
	let li_ano      = year(a_vig_ini) + 1;
    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
elif a_tiempo2 = 3 then		--Seis meses de exclusion
	let li_mes = month(a_vig_ini) + 6;
	if li_mes > 12 then
		let li_mes      = li_mes - 12;
		let li_ano      = year(a_vig_ini) + 1;
	    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
	end if 
end if

if a_excl2 is not null or a_excl2 <> "" then --exclusion1

	insert into emiprede(
		   no_poliza,
		   no_unidad,
		   cod_cliente,
		   cod_procedimiento,
		   fecha,
		   user_added,
		   date_added
		   )	
	       values (
	        a_no_poliza,
	        a_no_unidad,
	        a_cod_depen,
	        a_excl2,       		
			_fecha_excl,
			a_usuario_eval,
			v_fecha_r
			);


end if

if a_tiempo3 = 1 then 		--Permanente no lleva fecha
	let _fecha_excl = null;
elif a_tiempo3 = 2 then		--Un ano de exclusion
	let li_ano      = year(a_vig_ini) + 1;
    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
elif a_tiempo3 = 3 then		--Seis meses de exclusion
	let li_mes = month(a_vig_ini) + 6;
	if li_mes > 12 then
		let li_mes      = li_mes - 12;
		let li_ano      = year(a_vig_ini) + 1;
	    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
	end if 
end if

if a_excl3 is not null or a_excl3 <> "" then --exclusion1

	insert into emiprede(
		   no_poliza,
		   no_unidad,
		   cod_cliente,
		   cod_procedimiento,
		   fecha,
		   user_added,
		   date_added
		   )	
	       values (
	        a_no_poliza,
	        a_no_unidad,
	        a_cod_depen,
	        a_excl3,       		
			_fecha_excl,
			a_usuario_eval,
			v_fecha_r
			);

end if
if a_tiempo4 = 1 then 		--Permanente no lleva fecha
	let _fecha_excl = null;
elif a_tiempo4 = 2 then		--Un ano de exclusion
	let li_ano      = year(a_vig_ini) + 1;
    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
elif a_tiempo4 = 3 then		--Seis meses de exclusion
	let li_mes = month(a_vig_ini) + 6;
	if li_mes > 12 then
		let li_mes      = li_mes - 12;
		let li_ano      = year(a_vig_ini) + 1;
	    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
	end if 
end if

if a_excl4 is not null or a_excl4 <> "" then --exclusion1

	insert into emiprede(
		   no_poliza,
		   no_unidad,
		   cod_cliente,
		   cod_procedimiento,
		   fecha,
		   user_added,
		   date_added
		   )	
	       values (
	        a_no_poliza,
	        a_no_unidad,
	        a_cod_depen,
	        a_excl4,       		
			_fecha_excl,
			a_usuario_eval,
			v_fecha_r
			);

end if
if a_tiempo5 = 1 then 		--Permanente no lleva fecha
	let _fecha_excl = null;
elif a_tiempo5 = 2 then		--Un ano de exclusion
	let li_ano      = year(a_vig_ini) + 1;
    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
elif a_tiempo5 = 3 then		--Seis meses de exclusion
	let li_mes = month(a_vig_ini) + 6;
	if li_mes > 12 then
		let li_mes      = li_mes - 12;
		let li_ano      = year(a_vig_ini) + 1;
	    let _fecha_excl = MDY(li_mes, li_dia, li_ano);
	end if 
end if

if a_excl5 is not null or a_excl5 <> "" then --exclusion1

	insert into emiprede(
		   no_poliza,
		   no_unidad,
		   cod_cliente,
		   cod_procedimiento,
		   fecha,
		   user_added,
		   date_added
		   )	
	       values (
	        a_no_poliza,
	        a_no_unidad,
	        a_cod_depen,
	        a_excl5,
			_fecha_excl,
			a_usuario_eval,
			v_fecha_r
			);

end if
END
RETURN 0;
end procedure;
