--DROP procedure sp_pro04_2;
--DROP procedure sp_pro04_1;
drop procedure sp_pro04bk;
create procedure "informix".sp_pro04bk(
a_compania		char(3),
a_agencia		char(255)	default "*",
a_periodo		date,
a_codsucursal	char(255)	default "*",
a_codramo		char(255)	default "*")

returning	dec(16,2),	--1. v_rango_inicial
			dec(16,2),	--2. v_rango_final
			integer,	--3. tot_cant
			dec(16,2),	--4. v_prima_suscrita
			dec(16,2),	--5. v_prima_retenida
			integer,	--6. v_unidades
			char(3),	--7. v_codramo
			char(45),	--8. v_desc_ramo
			date,		--9. a_periodo
			char(45),	--10. descr_cia
			char(255),	--11. v_filtros
			dec(16,2),	--12. v_suma_asegurada / v_unidades
			dec(16,2),	--13. v_suma_asegurada
			dec(16,2),	--14. _prima_ret_casco
			dec(16,2),	--15. _prima_cont
			dec(16,2),	--16. _sum_retencion
			dec(16,2),	--17. _sum_ret_casco
			dec(16,2),	--18. _suma_fac
			dec(16,2),	--19. _suma_fac_car
			dec(16,2);	--20. _sum_cont

--------------------------------------------
---  PERFIL DE CARTERA - RAMOS AUTOMOVIL   ---
---            POLIZAS VIGENTES            ---
---  EXCLUYENDO COASEGUROS Y CONTRATOS
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_prod_sp_pro04
----------------------------------------------

define v_filtros		char(255);
define v_desc_ramo		char(45);
define descr_cia		char(45);
define v_nodocumento	char(20);
define _no_poliza		char(10);
define _cod_contrato	char(5);
define _no_endoso		char(5);
define _cod_cober_reas	char(3);
define v_codsubramo		char(3);
define v_codsucursal	char(3);
define v_codramo		char(3);
define _tipo			char(1);
define _prima_ret_casco	dec(16,2);
define v_prima_suscrita	dec(16,2);
define v_prima_retenida	dec(16,2);
define v_suma_asegurada	integer; --dec(16,2);
define v_rango_inicial	dec(16,2);
define _prima_suscrita	dec(16,2);
define _prima_retenida	dec(16,2);
define _suma_asegurada	dec(16,2);
define _sum_retencion	dec(16,2);
define _sum_ret_casco	dec(16,2);
define _suma_aseg_end	dec(16,2);
define _suma_fac_car	dec(16,2);
define v_rango_final	dec(16,2);
define suma_compara		dec(16,2);
define _prima_cont		dec(16,2);
define _sum_cont		dec(16,2);
define _suma_fac		dec(16,2);
define _rango_min		dec(16,2);
define _prima			dec(16,2);
define v_seleccionado	smallint;
define _tipo_contrato	smallint;
define v_cant_polizas	integer;
define v_unidades		integer;
define rango_max		integer;
define unidades1		integer;
define unidades2		integer;
define tot_cant			integer;
define v_fecha_cancel	date;

--SET DEBUG FILE TO "sp_pro04bk.trc"; 


create temp table temp_polizav
	(cod_ramo		char(03),
	cod_sucursal	char(03),
	rango_inicial	dec(16,2),
	rango_final		dec(16,2),
	prima_suscrita	dec(16,2),
	prima_retenida	dec(16,2),
	prima_ret_casco	dec(16,2),
	prima_contrato	dec(16,2),
	suma_retencion	dec(16,2),
	suma_ret_casco	dec(16,2),
	suma_ret_cont	dec(16,2),
	suma_facult		dec(16,2),
	suma_fac_car	dec(16,2),
	unidades		integer,
	seleccionado	smallint default 1,
	suma_asegurada	dec(16,2),	
primary key (cod_ramo,rango_inicial)) with no log;

create temp table temp_cant
	(no_documento	char(20),
	cod_ramo		char(3),
	cod_sucursal	char(3),
	rango_inicial	dec(16,2),
	cant_polizas	int,
	seleccionado	smallint default 1,
primary key (no_documento,cod_ramo,rango_inicial)) with no log;

create temp table temp_poliza
	(no_poliza		char(10),
	no_documento	char(20),
	cod_ramo		char(3),
	cod_sucursal	char(3),
	suma_asegurada	dec(16,2),
	prima_suscrita	dec(16,2),
	prima_retenida	dec(16,2),
	prima_ret_casco	dec(16,2),
	prima_contrato	dec(16,2),
	suma_retencion	dec(16,2),
	suma_ret_casco	dec(16,2),
	suma_ret_cont	dec(16,2),
	suma_facult		dec(16,2),
	suma_fac_car	dec(16,2),
	unidades		integer,
primary key (no_poliza)) with no log;
	  
let v_codsucursal		= null;
let v_desc_ramo			= null;
let _no_poliza			= null;
let v_codramo			= null;
let v_filtros			= null;
let descr_cia			= null;
let v_prima_retenida	= 0.00;
let _prima_ret_casco	= 0.00;
let v_prima_suscrita	= 0.00;
let _prima_suscrita 	= 0.00;
let _prima_retenida		= 0.00;
let _sum_ret_casco		= 0.00;
let _sum_retencion		= 0.00;
let _suma_fac_car		= 0.00;
let _prima_cont			= 0.00;
let _sum_cont			= 0.00;
let _suma_fac			= 0.00;
let v_rango_inicial		= 0;
let v_seleccionado		= 1;
let v_cant_polizas		= 0;
let v_rango_final		= 0;
let v_unidades			= 0;
let unidades1			= 0;
let unidades2			= 0;
let tot_cant			= 0;
 
let descr_cia = sp_sis01(a_compania);
call sp_pro83(a_compania,a_agencia,a_periodo,a_codramo) returning v_filtros;

if a_codsucursal <> "*" then
	let v_filtros = trim(v_filtros) ||"Sucursal "||trim(a_codsucursal);
	let _tipo = sp_sis04(a_codsucursal); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal not in(select codigo from tmp_codigos);
	else
		update temp_perfil
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if

foreach with hold
	select y.no_poliza,
		   y.no_endoso,
		   y.no_documento,
		   y.cod_sucursal,
		   y.cod_ramo,
		   y.cod_subramo,
		   y.suma_asegurada
	  into _no_poliza,
		   _no_endoso,
		   v_nodocumento,
		   v_codsucursal,
		   v_codramo,
		   v_codsubramo,
		   v_suma_asegurada
	  from temp_perfil y,emitipro z
	 where y.seleccionado  = 1
	   and y.cod_tipoprod  = z.cod_tipoprod
	   and z.tipo_produccion  in (1,4)
	   and y.cod_grupo not in ('00069', '00081', '00056', '00060', '00051')
	   
	   SELECT COUNT(no_unidad)
         INTO v_unidades
         FROM emipouni
        WHERE no_poliza = _no_poliza;

      { IF v_unidades IS NULL OR v_unidades = 0  THEN
          LET v_unidades = 0;
          CONTINUE FOREACH;
       END IF;}
	
	let v_prima_retenida	= 0.00;
	let _prima_ret_casco	= 0.00;
	let v_prima_suscrita	= 0.00;
	let _prima_suscrita 	= 0.00;
	let _prima_retenida		= 0.00;
	let _suma_aseg_end		= 0.00;
	let _sum_ret_casco		= 0.00;
	let _sum_retencion		= 0.00;
	let _suma_fac_car		= 0.00;
	let _prima_cont			= 0.00;
	let _sum_cont			= 0.00;
	let _suma_fac			= 0.00;
	
	select prima_suscrita,
		   suma_asegurada
	  into _prima_suscrita,
		   _suma_aseg_end
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
	
	foreach
		select cod_cober_reas,
			   cod_contrato,
			   prima,
			   suma_asegurada
		  into _cod_cober_reas,
			   _cod_contrato,
			   _prima,
			   _suma_asegurada
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		
		select tipo_contrato
		  into _tipo_contrato
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _tipo_contrato = 1 then
			if _cod_cober_reas in('002','033') then
				let _prima_retenida = _prima_retenida + _prima; 		--Prima Retenida RC
				let _sum_retencion = _sum_retencion + _suma_asegurada; 	--Suma Aseg Retenida RC
			else
				let _prima_ret_casco = _prima_ret_casco + _prima;	--Prima Retenida Casco
				let _sum_ret_casco = _sum_ret_casco + _suma_asegurada;
			end if
		elif _tipo_contrato = 3 then	--Facultativo
			--let _prima_fac = _prima_fac + _prima;
			let _suma_fac = _suma_fac + _suma_asegurada;
		else
			if _cod_contrato = "00574" or _cod_contrato = "00584" or _cod_contrato = "00594" or _cod_contrato = "00604" then
			   --let _prima_fac_car = _prima_fac_car + _prima;
			   let _suma_fac_car = _suma_fac_car + _suma_asegurada;
			else
			   let _prima_cont = _prima_cont + _prima;
			   let _sum_cont = _sum_cont + _suma_asegurada;
			end if
		end if
	end foreach
	
	let v_suma_asegurada = _sum_retencion + _sum_ret_casco + _suma_fac + _suma_fac_car + _sum_cont;
	
	if v_suma_asegurada <> 0 then
		if abs (_suma_aseg_end - v_suma_asegurada) > 1.00 then
			let _sum_retencion	= ((_sum_retencion * _suma_aseg_end)/v_suma_asegurada);
			let _sum_ret_casco	= ((_sum_ret_casco * _suma_aseg_end)/v_suma_asegurada);
			let _suma_fac_car	= ((_suma_fac_car * _suma_aseg_end)/v_suma_asegurada);
			let _sum_cont		= ((_sum_cont * _suma_aseg_end)/v_suma_asegurada);
			let _suma_fac		= ((_suma_fac * _suma_aseg_end)/v_suma_asegurada);
			let v_suma_asegurada = _suma_aseg_end;
		end if
	end if
	
	begin
		on exception in(-239)
			update temp_poliza
			   set suma_asegurada	= suma_asegurada	+ v_suma_asegurada,
				   prima_suscrita	= prima_suscrita	+ _prima_suscrita,
				   prima_retenida	= prima_retenida	+ _prima_retenida,
				   prima_ret_casco	= prima_ret_casco	+ _prima_ret_casco,
				   prima_contrato	= prima_contrato	+ _prima_cont,
				   suma_retencion	= suma_retencion	+ _sum_retencion,
				   suma_ret_casco	= suma_ret_casco	+ _sum_ret_casco,
				   suma_ret_cont	= suma_ret_cont		+ _sum_cont,
				   suma_facult		= suma_facult		+ _suma_fac,
				   suma_fac_car		= suma_fac_car		+ _suma_fac_car
				   --unidades			= unidades + v_unidades
			 where no_poliza = _no_poliza;

		end exception

		insert into temp_poliza
		values(	_no_poliza,
				v_nodocumento,
				v_codramo,
				v_codsucursal,
				v_suma_asegurada,
				_prima_suscrita,
				_prima_retenida,
				_prima_ret_casco,
				_prima_cont,
				_sum_retencion,
				_sum_ret_casco,
				_sum_cont,
				_suma_fac,
				_suma_fac_car,
				v_unidades);
	end
	let v_unidades = 0;
end foreach

foreach
	select no_poliza,  
		   no_documento,
		   cod_ramo,
		   cod_sucursal,
		   suma_asegurada,
		   prima_suscrita,
		   prima_retenida,
		   prima_ret_casco,
		   prima_contrato,
		   suma_retencion,
		   suma_ret_casco,
		   suma_ret_cont,
		   suma_facult,
		   suma_fac_car,
		   unidades 
	  into _no_poliza,
		   v_nodocumento,
		   v_codramo,
		   v_codsucursal,
		   v_suma_asegurada,
		   _prima_suscrita,
		   _prima_retenida,
		   _prima_ret_casco,
		   _prima_cont,
		   _sum_retencion,
		   _sum_ret_casco,
		   _sum_cont,
		   _suma_fac,
		   _suma_fac_car,
		   v_unidades
	  from temp_poliza

	if  v_suma_asegurada < 0 then
		let suma_compara = 0;
	else
		let suma_compara = v_suma_asegurada;
	end if

	{select rango1,
		   rango2
	  into v_rango_inicial,
		   v_rango_final
	  from parinfra
	 where cod_ramo = v_codramo
	   and rango1 >= suma_compara
	   and rango2 <= suma_compara;}
	   
	select rango1,
		   rango2
	  into v_rango_inicial,
		   v_rango_final
	  from parinfra
	 where cod_ramo = v_codramo
	   and suma_compara between rango1 and rango2;

	begin
		on exception in(-239)
			update temp_polizav
			   set prima_suscrita	= prima_suscrita	+ _prima_suscrita,
				   prima_retenida	= prima_retenida	+ _prima_retenida,
				   prima_ret_casco	= prima_ret_casco	+ _prima_ret_casco,
				   prima_contrato	= prima_contrato	+ _prima_cont,
				   suma_retencion	= suma_retencion	+ _sum_retencion,
				   suma_ret_casco	= suma_ret_casco	+ _sum_ret_casco,
				   suma_ret_cont	= suma_ret_cont		+ _sum_cont,
				   suma_facult		= suma_facult		+ _suma_fac,
				   suma_fac_car		= suma_fac_car		+ _suma_fac_car,
				   unidades			= unidades			+ v_unidades,
				   suma_asegurada	= suma_asegurada	+ v_suma_asegurada --suma_compara
			 where cod_ramo			= v_codramo
			   and rango_inicial	= v_rango_inicial;

		end exception
		
		insert into temp_polizav
		values(	v_codramo,
				v_codsucursal,
				v_rango_inicial,
				v_rango_final,
				_prima_suscrita,
				_prima_retenida,
				_prima_ret_casco,
				_prima_cont,
				_sum_retencion,
				_sum_ret_casco,
				_sum_cont,
				_suma_fac,
				_suma_fac_car,
				v_unidades,
				1,
				v_suma_asegurada); --suma_compara);
	end 

	begin
		on exception in(-239)
			-- no hace nada
		end exception
		
		insert into temp_cant
		values(	v_nodocumento,
				v_codramo,
				v_codsucursal,
				v_rango_inicial,
				1,
				1);
	end;
end foreach

foreach
	select *
	  into v_codramo,
		   v_codsucursal,
		   v_rango_inicial,
		   v_rango_final,
		   v_prima_suscrita,
		   v_prima_retenida,
		   _prima_ret_casco,
		   _prima_cont,
		   _sum_retencion,
		   _sum_ret_casco,
		   _sum_cont,
		   _suma_fac,
		   _suma_fac_car,
		   v_unidades,
		   v_seleccionado,
		   v_suma_asegurada
	  from temp_polizav
	 where seleccionado = 1
	 order by cod_ramo,rango_inicial

	foreach
		select cant_polizas
		  into v_cant_polizas
		  from temp_cant
		 where cod_ramo      = v_codramo
		   and rango_inicial = v_rango_inicial 
  
		let tot_cant = tot_cant + v_cant_polizas;  
	end foreach 

	select max(rango1)
	  into rango_max
	  from parinfra
	 where parinfra.cod_ramo = v_codramo;

	select min(rango1)
	  into _rango_min
	  from parinfra
	 where cod_ramo = v_codramo;

	if rango_max = v_rango_inicial then
		let v_rango_final = -1;
	end if;

	if _rango_min = v_rango_inicial then
		let v_rango_inicial = -1;
	end if;

	select nombre
	  into v_desc_ramo
	  from prdramo
	 where cod_ramo = v_codramo;

	return v_rango_inicial,					--1
		   v_rango_final,					--2
		   tot_cant,						--3
		   v_prima_suscrita,				--4
		   v_prima_retenida,				--5
		   v_unidades,						--6
		   v_codramo,						--7
		   v_desc_ramo,						--8
		   a_periodo,						--9
		   descr_cia,						--10
		   v_filtros,						--11
		   v_suma_asegurada / v_unidades,	--12
		   v_suma_asegurada,				--13
		   _prima_ret_casco,				--14
		   _prima_cont,						--15
		   _sum_retencion,					--16
		   _sum_ret_casco,					--17
		   _suma_fac,						--18
		   _suma_fac_car,					--19
		   _sum_cont  with resume;			--20
		   
	let tot_cant = 0;
end foreach

drop table temp_polizav;
drop table temp_poliza;
drop table temp_perfil;
drop table temp_cant;

end procedure;