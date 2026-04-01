-- Proceso que genera tmp_reas con la distribución de reaseguro para todas las unidades de una póliza.

-- creado    : 26/10/2015 - Autor: Román Gordón
-- sis v.2.0 - deivid, s.a.

drop procedure sp_sis219;
create procedure "informix".sp_sis219(a_no_poliza char(10))

returning	integer,
			char(5),
			char(5); 

define _motivo_rechazo	varchar(50);
define _error_desc		varchar(50);
define _nombre_pagad	char(100);
define _no_documento	char(20);
define _no_tarjeta		char(19);
define _cod_contratante	char(10);
define _cod_pagador		char(10);
define _no_factura		char(10);
define _fecha_exp		char(7);
define _periodo			char(7);
define _no_endoso_char	char(5);
define _no_endoso_ext	char(5);
define _no_unidad		char(5);
define _cod_formapag	char(3);
define _cod_endomov		char(3);
define _cod_perpago		char(3);
define _cod_banco		char(3);
define _periodo_tar		char(1);
define _tipo_tarjeta	char(1);
define _null			char(1);
define _nuevo_monto_visa	dec(16,2);
define _monto_visa		dec(16,2);
define _saldo_x_unidad	smallint;
define _no_pagos_campl	smallint;
define _letras_extras	smallint;
define _dia				smallint;
define _no_endoso_int	integer;
define _secuencia		integer;
define _cantidad		integer;
define _no_pagos		integer;
define _error			integer;
define _vigencia_final	date;
define _vigencia_inic	date;
define _fecha_1_pago	date;
define _cnt             integer;

--set debug file to "sp_sis23.trc"; 
--trace on;

set isolation to dirty read;

let _no_endoso_char = '';
let _no_tarjeta = '';
let _no_unidad = '';
let _saldo_x_unidad = 0;
let _dia = 0;

begin
on exception set _error 
 	return _error, _no_endoso_char, _no_unidad;         
end exception  

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

if _cod_ramo in ("001", "003") then

	foreach
		select cod_contrato,
			   cod_cober_reas,
			   sum(prima),
			   no_unidad,
			   porc_partic_prima
		  into _cod_contrato,
			   _cod_cober_reas,
			   _prima,
			   _no_unidad,
			   _porc_partic_prima
		  from emifacon
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		 group by no_unidad, cod_contrato, cod_cober_reas,porc_partic_prima


		select bouquet
		  into _bouquet
		  from reacocob
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		select es_terremoto
		  into _es_terremoto
		  from reacobre
		 where cod_cober_reas = _cod_cober_reas;

		begin
			on exception in(-239,-268)
				update tmp_unidad
				   set prima_tot = prima_tot + _prima
				 where no_unidad = _no_unidad;
			end exception
			
			insert into tmp_unidad(no_unidad,prima_tot)
			values(	_no_unidad,_prima);
		end

		insert into tmp_reas
		values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);
	end foreach

	-- Cuando el Contrato Es Bouquet
	let _bouquet = 1;

	if _cod_ramo = '001' then
		let _porc_inc = .70;
		let _porc_ter = .30;		
	else
		let _porc_inc = .90;
		let _porc_ter = .10;
	end if

	foreach
		select distinct no_unidad,
			   cod_contrato,
			   porc_partic_prima
		  into _no_unidad,
			   _cod_contrato,
			   _porc_partic_prima
		  from tmp_reas
		 where bouquet = 1
		 order by no_unidad, cod_contrato,porc_partic_prima

		select prima_tot
		  into _prima_tot
		  from tmp_unidad
		 where no_unidad = _no_unidad;

		select count(*)
		  into _cnt_existe
		  from reacocob c, reacobre r
		 where c.cod_cober_reas = r.cod_cober_reas
		   and c.cod_contrato = _cod_contrato
		   and r.cod_ramo = _cod_ramo
		   and es_terremoto = 1;

		if _cnt_existe is null then
			let _cnt_existe = 0;
		end if

		if _cnt_existe > 0 then
			let _porc_inc = .70;
			let _porc_ter = .30; 
		end if

		select count(*)
		  into _cantidad
		  from tmp_reas
		 where no_unidad    = _no_unidad
		   and cod_contrato = _cod_contrato
		   and es_terremoto = 0;

		if _cantidad = 0 then

			select cod_cober_reas,
				   es_terremoto
			  into _cod_cober_reas,
				   _es_terremoto
			  from reacobre
			 where cod_ramo     = _cod_ramo
			   and es_terremoto = 0;

			insert into tmp_reas
			values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);

		end if

		update tmp_reas
		   set prima_rea    = prima_rea + (_prima_tot * _porc_inc) * (_porc_partic_prima/100)
		 where no_unidad    = _no_unidad
		   and cod_contrato = _cod_contrato
		   and porc_partic_prima = _porc_partic_prima
		   and es_terremoto = 0;

		select count(*)
		  into _cantidad
		  from tmp_reas
		 where no_unidad    = _no_unidad
		   and cod_contrato = _cod_contrato
		   and es_terremoto = 1;

		if _cantidad = 0 and _cnt_existe > 0 then

			select cod_cober_reas,
				   es_terremoto
			  into _cod_cober_reas,
				   _es_terremoto
			  from reacobre
			 where cod_ramo     = _cod_ramo
			   and es_terremoto = 1;

			insert into tmp_reas
			values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);

		end if

		update tmp_reas
		   set prima_rea    = prima_rea + (_prima_tot * _porc_ter) * (_porc_partic_prima/100)
		 where no_unidad    = _no_unidad
		   and cod_contrato = _cod_contrato
		   and porc_partic_prima = _porc_partic_prima
		   and es_terremoto = 1;
	end foreach

	-- Cuando el Contrato No Es Bouquet

	foreach
		select no_unidad,
			   cod_cober_reas,
			   cod_contrato
		  into _no_unidad,
			   _cod_cober_reas,
			   _cod_contrato
		  from tmp_reas
		 where bouquet = 0

		select prima
		  into _prima
		  from dep_emifacon
		 where no_poliza      = a_no_poliza
		   and no_endoso      = a_no_endoso
		   and no_unidad      = _no_unidad
		   and cod_cober_reas = _cod_cober_reas
		   and cod_contrato   = _cod_contrato;

		update tmp_reas
		   set prima_rea      = _prima
		 where no_unidad      = _no_unidad
		   and cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

	end foreach
else	
	foreach
		select cod_contrato,
			   prima,
			   cod_cober_reas,
			   no_unidad,
			   orden,
			   porc_partic_prima
		  into _cod_contrato,
			   _prima,
			   _cod_cober_reas,
			   _no_unidad,
			   _orden,
			   _porc_partic_prima
		  from dep_emifacon
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso

		insert into tmp_reas
		values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, _prima, 0, 0, _orden,_porc_partic_prima);
	end foreach
end if
