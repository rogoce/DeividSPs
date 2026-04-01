-- Roll 12
-- 
-- Creado    : 04/07/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 04/07/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro125;

create procedure "informix".sp_pro125(
a_compania	char(3), 
a_agencia 	char(3), 
a_periodo1 	char(7), 
a_periodo2 	char(7),
a_posicion	smallint
)

define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _cod_ramo      	char(3);
define _cod_subramo   	char(3);
define _cod_grupo     	char(5);

define _rec_abierto1   	integer;
define _rec_abierto2   	integer;
define _rec_abierto3   	integer;
define _rec_abierto4   	integer;
define _rec_abierto5   	integer;
define _rec_abierto6   	integer;

define _incurrido_neto  dec(16,2);
define _incurrido_neto1 dec(16,2);
define _incurrido_neto2 dec(16,2);
define _incurrido_neto3 dec(16,2);
define _incurrido_neto4 dec(16,2);
define _incurrido_neto5 dec(16,2);
define _incurrido_neto6 dec(16,2);

define _cant_unidades	integer;
define _cant_unidades1	integer;
define _cant_unidades2	integer;
define _cant_unidades3	integer;
define _cant_unidades4	integer;
define _cant_unidades5	integer;
define _cant_unidades6	integer;

define _prima_suscrita	dec(16,2);
define _prima_suscrita1	dec(16,2);
define _prima_suscrita2	dec(16,2);
define _prima_suscrita3	dec(16,2);
define _prima_suscrita4	dec(16,2);
define _prima_suscrita5	dec(16,2);
define _prima_suscrita6	dec(16,2);


define _cod_endomov		char(3);
define _tipo_mov		smallint;
define _fecha			date;

define v_filtros		char(255);

-- Incurrido Neto

CALL sp_rec01(a_compania, a_agencia, a_periodo1, a_periodo2)
              RETURNING v_filtros;

let _rec_abierto1    = 0;   
let _rec_abierto2    = 0;   
let _rec_abierto3    = 0;   
let _rec_abierto4    = 0;   
let _rec_abierto5    = 0;   
let _rec_abierto6    = 0;   

let _incurrido_neto1 = 0.00;
let _incurrido_neto2 = 0.00;
let _incurrido_neto3 = 0.00;
let _incurrido_neto4 = 0.00;
let _incurrido_neto5 = 0.00;
let _incurrido_neto6 = 0.00;

let _cant_unidades1  = 0;   
let _cant_unidades2  = 0;   
let _cant_unidades3  = 0;   
let _cant_unidades4  = 0;   
let _cant_unidades5  = 0;   
let _cant_unidades6  = 0;   

let _prima_suscrita1 = 0.00;
let _prima_suscrita2 = 0.00;
let _prima_suscrita3 = 0.00;
let _prima_suscrita4 = 0.00;
let _prima_suscrita5 = 0.00;
let _prima_suscrita6 = 0.00;

foreach
 select cod_ramo,
		cod_subramo,
		cod_grupo,
	    sum(incurrido_bruto)
   into _cod_ramo,
		_cod_subramo,
		_cod_grupo,
	    _incurrido_neto
   from tmp_sinis
  group by 1, 2, 3

	if a_posicion = 1 then
		let _incurrido_neto1 = _incurrido_neto;
	elif a_posicion = 2 then
		let _incurrido_neto2 = _incurrido_neto;
	elif a_posicion = 3 then
		let _incurrido_neto3 = _incurrido_neto;
	elif a_posicion = 4 then
		let _incurrido_neto4 = _incurrido_neto;
	elif a_posicion = 5 then
		let _incurrido_neto5 = _incurrido_neto;
	elif a_posicion = 6 then
		let _incurrido_neto6 = _incurrido_neto;
	end if		

	insert into temp_roll_12(
	cod_ramo,
	cod_subramo,
	cod_grupo,
	rec_abierto1,
	rec_abierto2,
	rec_abierto3,
	rec_abierto4,
	rec_abierto5,
	rec_abierto6,
	incurrido_neto1,
	incurrido_neto2,
	incurrido_neto3,
	incurrido_neto4,
	incurrido_neto5,
	incurrido_neto6,
	cant_unidades1,
	cant_unidades2,
	cant_unidades3,
	cant_unidades4,
	cant_unidades5,
	cant_unidades6,
	prima_suscrita1,
	prima_suscrita2,
	prima_suscrita3,
	prima_suscrita4,
	prima_suscrita5,
	prima_suscrita6
	)
	values(
	_cod_ramo,
	_cod_subramo,
	_cod_grupo,
	_rec_abierto1,
	_rec_abierto2,
	_rec_abierto3,
	_rec_abierto4,
	_rec_abierto5,
	_rec_abierto6,
	_incurrido_neto1,
	_incurrido_neto2,
	_incurrido_neto3,
	_incurrido_neto4,
	_incurrido_neto5,
	_incurrido_neto6,
	_cant_unidades1,
	_cant_unidades2,
	_cant_unidades3,
	_cant_unidades4,
	_cant_unidades5,
	_cant_unidades6,
	_prima_suscrita1,
	_prima_suscrita2,
	_prima_suscrita3,
	_prima_suscrita4,
	_prima_suscrita5,
	_prima_suscrita6
	);

end foreach

-- Cantidad de Reclamos

let _rec_abierto1    = 0;   
let _rec_abierto2    = 0;   
let _rec_abierto3    = 0;   
let _rec_abierto4    = 0;   
let _rec_abierto5    = 0;   
let _rec_abierto6    = 0;   

let _incurrido_neto1 = 0.00;
let _incurrido_neto2 = 0.00;
let _incurrido_neto3 = 0.00;
let _incurrido_neto4 = 0.00;
let _incurrido_neto5 = 0.00;
let _incurrido_neto6 = 0.00;

let _cant_unidades1  = 0;   
let _cant_unidades2  = 0;   
let _cant_unidades3  = 0;   
let _cant_unidades4  = 0;   
let _cant_unidades5  = 0;   
let _cant_unidades6  = 0;   

let _prima_suscrita1 = 0.00;
let _prima_suscrita2 = 0.00;
let _prima_suscrita3 = 0.00;
let _prima_suscrita4 = 0.00;
let _prima_suscrita5 = 0.00;
let _prima_suscrita6 = 0.00;

if a_posicion = 1 then
	let _rec_abierto1	= 1;
elif a_posicion = 2 then
	let _rec_abierto2	= 1;
elif a_posicion = 3 then
	let _rec_abierto3	= 1;
elif a_posicion = 4 then
	let _rec_abierto4	= 1;
elif a_posicion = 5 then
	let _rec_abierto5	= 1;
elif a_posicion = 6 then
	let _rec_abierto6	= 1;
end if		

foreach
 select no_poliza
   into _no_poliza
   from recrcmae
  where periodo    >= a_periodo1
    and periodo    <= a_periodo2
	and actualizado = 1

	select cod_ramo,
	       cod_subramo,
		   cod_grupo
	  into _cod_ramo,
	       _cod_subramo,
		   _cod_grupo
	  from emipomae
	 where no_poliza = _no_poliza;

	insert into temp_roll_12(
	cod_ramo,
	cod_subramo,
	cod_grupo,
	rec_abierto1,
	rec_abierto2,
	rec_abierto3,
	rec_abierto4,
	rec_abierto5,
	rec_abierto6,
	incurrido_neto1,
	incurrido_neto2,
	incurrido_neto3,
	incurrido_neto4,
	incurrido_neto5,
	incurrido_neto6,
	cant_unidades1,
	cant_unidades2,
	cant_unidades3,
	cant_unidades4,
	cant_unidades5,
	cant_unidades6,
	prima_suscrita1,
	prima_suscrita2,
	prima_suscrita3,
	prima_suscrita4,
	prima_suscrita5,
	prima_suscrita6
	)
	values(
	_cod_ramo,
	_cod_subramo,
	_cod_grupo,
	_rec_abierto1,
	_rec_abierto2,
	_rec_abierto3,
	_rec_abierto4,
	_rec_abierto5,
	_rec_abierto6,
	_incurrido_neto1,
	_incurrido_neto2,
	_incurrido_neto3,
	_incurrido_neto4,
	_incurrido_neto5,
	_incurrido_neto6,
	_cant_unidades1,
	_cant_unidades2,
	_cant_unidades3,
	_cant_unidades4,
	_cant_unidades5,
	_cant_unidades6,
	_prima_suscrita1,
	_prima_suscrita2,
	_prima_suscrita3,
	_prima_suscrita4,
	_prima_suscrita5,
	_prima_suscrita6
	);

end foreach

-- Prima Suscrita

let _rec_abierto1    = 0;   
let _rec_abierto2    = 0;   
let _rec_abierto3    = 0;   
let _rec_abierto4    = 0;   
let _rec_abierto5    = 0;   
let _rec_abierto6    = 0;   

let _incurrido_neto1 = 0.00;
let _incurrido_neto2 = 0.00;
let _incurrido_neto3 = 0.00;
let _incurrido_neto4 = 0.00;
let _incurrido_neto5 = 0.00;
let _incurrido_neto6 = 0.00;

let _cant_unidades1  = 0;   
let _cant_unidades2  = 0;   
let _cant_unidades3  = 0;   
let _cant_unidades4  = 0;   
let _cant_unidades5  = 0;   
let _cant_unidades6  = 0;   

let _prima_suscrita1 = 0.00;
let _prima_suscrita2 = 0.00;
let _prima_suscrita3 = 0.00;
let _prima_suscrita4 = 0.00;
let _prima_suscrita5 = 0.00;
let _prima_suscrita6 = 0.00;

foreach 
 select prima_suscrita,
        no_poliza,
		cod_endomov,
		no_endoso
   into _prima_suscrita,
        _no_poliza,
		_cod_endomov,
		_no_endoso
   from endedmae
  where periodo       >= a_periodo1
    and periodo       <= a_periodo2
    and actualizado    = 1
    and prima_suscrita <> 0.00  

	select cod_ramo,
	       cod_subramo,
		   cod_grupo
	  into _cod_ramo,
	       _cod_subramo,
		   _cod_grupo
	  from emipomae
	 where no_poliza = _no_poliza;

	let _cant_unidades = 0;

{   
	select tipo_mov
	  into _tipo_mov
	  from endtimov
	 where cod_endomov = _cod_endomov; 

    foreach
     select no_unidad
	   into _no_unidad
	   from endeduni
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso

		if _tipo_mov = 4  or	  -- incl.
		   _tipo_mov = 11 or	  -- poliza orig.
		   _tipo_mov = 3  then    -- rehab.
			let _cant_unidades = _cant_unidades + 1;
		end if
		if _tipo_mov = 5  or   -- eliminacion	
		   _tipo_mov = 2  or   -- cancelacion
		   _tipo_mov = 20 then -- cancelacion manual
			let _cant_unidades = _cant_unidades - 1;
		end if

	end foreach
}

	if a_posicion = 1 then
		let _prima_suscrita1 = _prima_suscrita;
		let _cant_unidades1  = _cant_unidades;
	elif a_posicion = 2 then
		let _prima_suscrita2 = _prima_suscrita;
		let _cant_unidades2  = _cant_unidades;
	elif a_posicion = 3 then
		let _prima_suscrita3 = _prima_suscrita;
		let _cant_unidades3  = _cant_unidades;
	elif a_posicion = 4 then
		let _prima_suscrita4 = _prima_suscrita;
		let _cant_unidades4  = _cant_unidades;
	elif a_posicion = 5 then
		let _prima_suscrita5 = _prima_suscrita;
		let _cant_unidades5  = _cant_unidades;
	elif a_posicion = 6 then
		let _prima_suscrita6 = _prima_suscrita;
		let _cant_unidades6  = _cant_unidades;
	end if		

	insert into temp_roll_12(
	cod_ramo,
	cod_subramo,
	cod_grupo,
	rec_abierto1,
	rec_abierto2,
	rec_abierto3,
	rec_abierto4,
	rec_abierto5,
	rec_abierto6,
	incurrido_neto1,
	incurrido_neto2,
	incurrido_neto3,
	incurrido_neto4,
	incurrido_neto5,
	incurrido_neto6,
	cant_unidades1,
	cant_unidades2,
	cant_unidades3,
	cant_unidades4,
	cant_unidades5,
	cant_unidades6,
	prima_suscrita1,
	prima_suscrita2,
	prima_suscrita3,
	prima_suscrita4,
	prima_suscrita5,
	prima_suscrita6,
	no_poliza
	)
	values(
	_cod_ramo,
	_cod_subramo,
	_cod_grupo,
	_rec_abierto1,
	_rec_abierto2,
	_rec_abierto3,
	_rec_abierto4,
	_rec_abierto5,
	_rec_abierto6,
	_incurrido_neto1,
	_incurrido_neto2,
	_incurrido_neto3,
	_incurrido_neto4,
	_incurrido_neto5,
	_incurrido_neto6,
	_cant_unidades1,
	_cant_unidades2,
	_cant_unidades3,
	_cant_unidades4,
	_cant_unidades5,
	_cant_unidades6,
	_prima_suscrita1,
	_prima_suscrita2,
	_prima_suscrita3,
	_prima_suscrita4,
	_prima_suscrita5,
	_prima_suscrita6,
	_no_poliza
	);

end foreach

-- Cantidad de Unidades

let _rec_abierto1    = 0;   
let _rec_abierto2    = 0;   
let _rec_abierto3    = 0;   
let _rec_abierto4    = 0;   
let _rec_abierto5    = 0;   
let _rec_abierto6    = 0;   

let _incurrido_neto1 = 0.00;
let _incurrido_neto2 = 0.00;
let _incurrido_neto3 = 0.00;
let _incurrido_neto4 = 0.00;
let _incurrido_neto5 = 0.00;
let _incurrido_neto6 = 0.00;

let _cant_unidades1  = 0;   
let _cant_unidades2  = 0;   
let _cant_unidades3  = 0;   
let _cant_unidades4  = 0;   
let _cant_unidades5  = 0;   
let _cant_unidades6  = 0;   

let _prima_suscrita1 = 0.00;
let _prima_suscrita2 = 0.00;
let _prima_suscrita3 = 0.00;
let _prima_suscrita4 = 0.00;
let _prima_suscrita5 = 0.00;
let _prima_suscrita6 = 0.00;

let _fecha = sp_sis36(a_periodo2);

call sp_pro03(a_compania, a_agencia, _fecha, "*") RETURNING v_filtros;

foreach
 select no_poliza
   into _no_poliza
   from temp_perfil
  group by 1
  order by 1

	select cod_ramo,
	       cod_subramo,
		   cod_grupo
	  into _cod_ramo,
	       _cod_subramo,
		   _cod_grupo
	  from emipomae
	 where no_poliza = _no_poliza;

	select count(*)
	  into _cant_unidades 
	  from emipouni
	 where no_poliza = _no_poliza;

	if a_posicion = 1 then
		let _cant_unidades1  = _cant_unidades;
	elif a_posicion = 2 then
		let _cant_unidades2  = _cant_unidades;
	elif a_posicion = 3 then
		let _cant_unidades3  = _cant_unidades;
	elif a_posicion = 4 then
		let _cant_unidades4  = _cant_unidades;
	elif a_posicion = 5 then
		let _cant_unidades5  = _cant_unidades;
	elif a_posicion = 6 then
		let _cant_unidades6  = _cant_unidades;
	end if		

	insert into temp_roll_12(
	cod_ramo,
	cod_subramo,
	cod_grupo,
	rec_abierto1,
	rec_abierto2,
	rec_abierto3,
	rec_abierto4,
	rec_abierto5,
	rec_abierto6,
	incurrido_neto1,
	incurrido_neto2,
	incurrido_neto3,
	incurrido_neto4,
	incurrido_neto5,
	incurrido_neto6,
	cant_unidades1,
	cant_unidades2,
	cant_unidades3,
	cant_unidades4,
	cant_unidades5,
	cant_unidades6,
	prima_suscrita1,
	prima_suscrita2,
	prima_suscrita3,
	prima_suscrita4,
	prima_suscrita5,
	prima_suscrita6
	)
	values(
	_cod_ramo,
	_cod_subramo,
	_cod_grupo,
	_rec_abierto1,
	_rec_abierto2,
	_rec_abierto3,
	_rec_abierto4,
	_rec_abierto5,
	_rec_abierto6,
	_incurrido_neto1,
	_incurrido_neto2,
	_incurrido_neto3,
	_incurrido_neto4,
	_incurrido_neto5,
	_incurrido_neto6,
	_cant_unidades1,
	_cant_unidades2,
	_cant_unidades3,
	_cant_unidades4,
	_cant_unidades5,
	_cant_unidades6,
	_prima_suscrita1,
	_prima_suscrita2,
	_prima_suscrita3,
	_prima_suscrita4,
	_prima_suscrita5,
	_prima_suscrita6
	);

end foreach

drop table temp_perfil;
drop table tmp_sinis;

end procedure



















