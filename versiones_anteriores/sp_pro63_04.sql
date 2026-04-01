--DROP procedure sp_pro04_2;
--DROP procedure sp_pro04_1;
-- Modificado: 25/04/2019 - HGIRON CASO:9155 
drop procedure sp_pro63_04;
create procedure "informix".sp_pro63_04(
a_compania		char(3),
a_agencia		char(255)	default "*",
a_periodo		date,
a_codsucursal	char(255)	default "*",
a_codramo		char(255)	default "*",
a_fecha         date, a_serie char(255) default "*")
RETURNING CHAR(255);
{returning	varchar(50),	--1. v_rango_inicial
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
			dec(16,2),	--20. _sum_cont
            dec(16,2);
			}
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
define v_suma_asegurada	dec(16,2); --integer; --dec(16,2);
define v_rango_inicial	dec(16,2);
define _prima_suscrita	dec(16,2);
define _prima_retenida	dec(16,2);
define _suma_asegurada	dec(16,2);
define _sum_retencion	dec(16,2);
define _sum_ret_casco	dec(16,2);
define _suma_aseg_end	dec(16,2);
define _suma_fac_car	dec(16,2);
define v_rango_final	dec(16,2);
define suma_compara		integer;
define _prima_cont		dec(16,2);
define _sum_cont		dec(16,2);
define _suma_fac		dec(16,2);
define _rango_min		dec(16,2);
define _prima			dec(16,2);
define v_seleccionado	smallint;
define _tipo_contrato	smallint;
define v_cant_polizas	integer;
define v_unidades		integer;
define rango_max		dec(16,2);
define unidades1		integer;
define unidades2		integer;
define tot_cant			integer;
define v_fecha_cancel	date;
define _no_unidad       char(5);
define v_unidades2      bigint;
define v_prima_cobrada  dec(16,2);
define _code_pais       char(3);
define _code_provincia  char(2);
define _cod_ubica       char(3);
define _cod_asegurado   char(10);
define _orden           smallint;
define _prima_cobrada   dec(16,2);
define v_ubicacion			varchar(50);
DEFINE _cod_traspaso	 CHAR(5);
DEFINE _serie,_serie1	 SMALLINT;
DEFINE _desc_contrato    CHAR(50);
DEFINE _traspaso		 SMALLINT;
define _excluir          smallint;
define _fecha_rehab			date;
define _estatus_poliza		smallint;
define _u_prima_suscrita, _u_suma_aseg_end dec(16,2);
--SET DEBUG FILE TO "sp_pro04bk.trc"; 


drop table if exists temp_poliza;
drop table if exists temp_polizav;
drop table if exists temp_cant;
drop table if exists temp_prima;


create temp table temp_polizav
	(cod_ramo		char(03),
	cod_sucursal	char(03),
	cod_ubica   	char(03),
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
	orden           smallint,
	prima_cobrada   dec(16,2),
primary key (cod_ramo,cod_ubica)) with no log;

create temp table temp_cant
	(no_documento	char(20),
	no_unidad       char(5),
	cod_ramo		char(3),
	cod_sucursal	char(3),
	cod_ubica   	char(03),
	cant_polizas	int,
	seleccionado	smallint default 1,
primary key (no_documento, no_unidad,cod_ramo,cod_ubica)) with no log;

create temp table temp_poliza
	(no_poliza		char(10),
	no_unidad       char(5),
	cod_ubica       char(3),
	no_documento	char(20),
	cod_ramo		char(3),
	cod_sucursal	char(3),
	suma_asegurada	dec(16,2) default 0.00,
	prima_suscrita	dec(16,2) default 0.00,
	prima_retenida	dec(16,2) default 0.00,
	prima_ret_casco	dec(16,2) default 0.00,
	prima_contrato	dec(16,2) default 0.00,
	suma_retencion	dec(16,2) default 0.00,
	suma_ret_casco	dec(16,2) default 0.00,
	suma_ret_cont	dec(16,2) default 0.00,
	suma_facult		dec(16,2) default 0.00,
	suma_fac_car	dec(16,2) default 0.00,
	unidades		integer,
				serie 			 SMALLINT,
                cod_contrato     CHAR(5),
				desc_contrato    CHAR(50),
                cod_cobertura    CHAR(3),				
				seleccionado	smallint default 1,
primary key (no_poliza, no_unidad)) with no log;

create temp table temp_prima
	(no_documento	char(20),
	prima_cobrada   dec(16,2),
	leido	        smallint default 0,
primary key (no_documento)) with no log;
	  
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
let _u_prima_suscrita   = 0.00;
let _u_suma_aseg_end    = 0.00;
let v_rango_inicial		= 0;
let v_seleccionado		= 1;
let v_cant_polizas		= 0;
let v_rango_final		= 0;
let v_unidades			= 0;
let unidades1			= 0;
let unidades2			= 0;
let tot_cant			= 0;

set isolation to dirty read;
 
let descr_cia = sp_sis01(a_compania);
--call sp_pro83(a_compania,a_agencia,a_periodo,a_codramo) returning v_filtros;
LET v_filtros = sp_pro03(a_compania,a_agencia,a_periodo,a_codramo);


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
	--	   y.no_endoso,
		   y.no_documento,
		   y.cod_sucursal,
		   y.cod_ramo,
		   y.cod_subramo,
		   y.suma_asegurada
	  into _no_poliza,
	--	   _no_endoso,
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
	   

		let _excluir = 0;     --- SD403# OMAR correo 13/04/2021 excluir BHN
		SELECT count(*) 
		  into _excluir 
		  FROM polexcluir
		 where no_documento = v_nodocumento;

			if  _excluir is null  then
		let _excluir = 0;
		end if

		if  _excluir <> 0 then
			continue foreach;
		end if	   
	   
	   SELECT COUNT(no_unidad)
         INTO v_unidades
         FROM emipouni
        WHERE no_poliza = _no_poliza;

	
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
	let _u_prima_suscrita   = 0.00;
	let _u_suma_aseg_end    = 0.00;	
	let v_prima_cobrada  	= 0.00;
	
	--let v_prima_cobrada     = sp_sis426(v_nodocumento, a_fecha, a_periodo);
	
	begin
		on exception in(-239)
		end exception

		insert into temp_prima
		values(	v_nodocumento,
        		v_prima_cobrada,
				0);
	end

    foreach		 
		select no_unidad, cod_asegurado, prima_suscrita, suma_asegurada		  
		  into _no_unidad, _cod_asegurado , _u_prima_suscrita, _u_suma_aseg_end
		  from emipouni
		 where no_poliza = _no_poliza
		 
		 select estatus_poliza
		  into _estatus_poliza
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		select code_pais, 
		       code_provincia
		  into _code_pais,
		       _code_provincia
		  from cliclien
		 where cod_cliente = _cod_asegurado;
		 
		select cod_ubica
		  into _cod_ubica
		  from genprov
		 where code_pais = _code_pais
		   and code_provincia = _code_provincia;
		
		foreach 
			select a.no_endoso
			  into _no_endoso
			  from endedmae a
			 where a.no_poliza = _no_poliza
			   and a.fecha_emision <= a_periodo
			
			select b.prima_suscrita, b.suma_asegurada
              into _prima_suscrita, _suma_aseg_end
              from endeduni b  
             where b.no_poliza = _no_poliza
			   and b.no_endoso = _no_endoso
			   and b.no_unidad = _no_unidad;

			if _suma_aseg_end is null then
				let _suma_aseg_end = 0;
			end if
			   
			let v_suma_asegurada = 0.00;					
			   
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
				   and no_unidad = _no_unidad
				
				{select tipo_contrato
				  into _tipo_contrato
				  from reacomae
				 where cod_contrato = _cod_contrato;}
				 
				select traspaso
				  into _traspaso
				  from reacocob
				 where cod_contrato   = _cod_contrato
				   and cod_cober_reas = _cod_cober_reas;

				Select cod_traspaso,
					   tipo_contrato,
					   serie
				  Into _cod_traspaso,
					   _tipo_contrato,
					   _serie
				  From reacomae
				 Where cod_contrato = _cod_contrato;

				if _traspaso = 1 then
					let _cod_contrato = _cod_traspaso;
				end if

		        SELECT nombre,
				       serie
		          INTO _desc_contrato,
				       _serie
		          FROM reacomae
		         WHERE cod_contrato = _cod_contrato;				 
				 

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
		
			if _sum_retencion is null then
				let _sum_retencion = 0;
			end if
			if _sum_ret_casco is null then
				let _sum_ret_casco = 0;
			end if
			if _suma_fac is null then
				let _suma_fac = 0;
			end if
			if _suma_fac_car is null then
				let _suma_fac_car = 0;
			end if
			if _sum_cont is null then
				let _sum_cont = 0;
			end if
			
			let v_suma_asegurada = _sum_retencion + _sum_ret_casco + _suma_fac + _suma_fac_car + _sum_cont;

			if _prima_suscrita is null then
				let _prima_suscrita = 0;
			end if
			if _prima_retenida is null then
				let _prima_retenida = 0;
			end if
			if _prima_ret_casco is null then
				let _prima_ret_casco = 0;
			end if
			if _prima_cont is null then
				let _prima_cont = 0;
			end if
			
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
					 where no_poliza = _no_poliza
					   and no_unidad = _no_unidad;

				end exception

				insert into temp_poliza
				values(	_no_poliza,
						_no_unidad,
						_cod_ubica,
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
						1,
						  _serie,
						  _cod_contrato,
						  _desc_contrato,
						  _cod_cober_reas,1);						
			end
			
			{if ( _estatus_poliza <> 4 and abs(_suma_aseg_end) = 0 and abs(v_suma_asegurada) = 0 ) then
				if _u_suma_aseg_end is null then
					let _u_suma_aseg_end = 0;
				end if	
			
				select max(fecha_emision)
				  into _fecha_rehab
				  from endedmae
				 where no_poliza = _no_poliza
				   and cod_endomov = '003'
				   and actualizado = 1;

				if _fecha_rehab <= a_periodo then
					update temp_poliza
				   set suma_asegurada	= suma_asegurada	+ _u_suma_aseg_end,
						   suma_retencion	= suma_retencion	+ _u_suma_aseg_end
					 where no_poliza = _no_poliza
					   and no_unidad = _no_unidad;
				end if
			end if}
			
			let v_unidades = 0;
			let _prima_retenida = 0;
			let v_suma_asegurada = 0;
			let _prima_suscrita = 0;
			let _prima_ret_casco = 0;
			let _prima_cont = 0;
			let _sum_retencion = 0;
			let _sum_ret_casco = 0;
			let _sum_cont = 0;
			let _suma_fac = 0;
			let _suma_fac_car = 0;
		end foreach
	end foreach
end foreach

-- HG:CASO: 31242
-- Filtro por Serie
IF a_serie <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||" Serie "||TRIM(a_serie);
	LET _tipo = sp_sis04(a_serie); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_poliza
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND serie NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE temp_poliza
		       SET seleccionado = 0
		     WHERE seleccionado = 1
		       AND serie IN(SELECT codigo FROM tmp_codigos);
		END IF
	DROP TABLE tmp_codigos;
END IF

--SET DEBUG FILE TO "sp_pro04bk.trc"; 
--trace on;

foreach
	select no_poliza,  
		   no_documento,
		   no_unidad,
		   cod_ramo,
		   cod_sucursal,
		   cod_ubica,
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
		   _no_unidad,
		   v_codramo,
		   v_codsucursal,
		   _cod_ubica,
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
     where seleccionado  = 1

	if  v_suma_asegurada < 0 or v_suma_asegurada is null then
		let suma_compara = 0;
	else
		let suma_compara = v_suma_asegurada;
	end if
	   
	let _orden = sp_sis184(_cod_ubica);	
	
	let _prima_cobrada = 0;
	
	select prima_cobrada
	  into _prima_cobrada
	  from temp_prima
	 where no_documento = v_nodocumento
	   and leido = 0;
	   
	update temp_prima
	   set leido = 1
	 where no_documento = v_nodocumento;
	 
	if _prima_cobrada is null then
		let _prima_cobrada = 0;
	end if
	   
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
				   suma_asegurada	= suma_asegurada	+ v_suma_asegurada, --suma_compara
				   prima_cobrada    = prima_cobrada     + _prima_cobrada
			 where cod_ramo			= v_codramo
			   and cod_ubica	    = _cod_ubica;

		end exception
		
		insert into temp_polizav(
			cod_ramo,
			cod_sucursal,
			cod_ubica,
			prima_suscrita,
			prima_retenida,
			prima_ret_casco,
			prima_contrato,
			suma_retencion,
			suma_ret_casco,
			suma_ret_cont,
			suma_facult,
			suma_fac_car,
			unidades,
			seleccionado,
			suma_asegurada,
			orden,
			prima_cobrada)
		values(	v_codramo,
				v_codsucursal,
				_cod_ubica,
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
				v_suma_asegurada,
				_orden,
				_prima_cobrada); --suma_compara);
	end 

	begin
		on exception in(-239)
		end exception
		
		insert into temp_cant
		values(	v_nodocumento,
		        _no_unidad, 
				v_codramo,
				v_codsucursal,
				_cod_ubica,
				1,
				1);
	end;
end foreach
return v_filtros;

{foreach
	select cod_ramo,
		   cod_sucursal,
			cod_ubica,
			prima_suscrita,
			prima_retenida,
			prima_ret_casco,
			prima_contrato,
			suma_retencion,
			suma_ret_casco,
			suma_ret_cont,
			suma_facult,
			suma_fac_car,
			seleccionado,
			unidades,
			suma_asegurada,
            prima_cobrada			
	  into v_codramo,
		   v_codsucursal,
		   _cod_ubica,
		   v_prima_suscrita,
		   v_prima_retenida,
		   _prima_ret_casco,
		   _prima_cont,
		   _sum_retencion,
		   _sum_ret_casco,
		   _sum_cont,
		   _suma_fac,
		   _suma_fac_car,
		   v_seleccionado,
		   v_unidades,
		   v_suma_asegurada,
		   _prima_cobrada
	  from temp_polizav
	 where seleccionado = 1
	 order by cod_ramo,orden

	foreach
		select cant_polizas
		  into v_cant_polizas
		  from temp_cant
		 where cod_ramo      = v_codramo
		   and cod_ubica     = _cod_ubica 
  
		let tot_cant = tot_cant + v_cant_polizas;  
	end foreach 	

	select nombre
	  into v_desc_ramo
	  from prdramo
	 where cod_ramo = v_codramo;
	 
	select nombre
	  into v_ubicacion
	  from emiubica
	 where cod_ubica = _cod_ubica;	 

	return v_ubicacion,					--2
		   v_unidades,					        --3
		   v_prima_suscrita,				--4
		   v_prima_retenida,				--5
		   v_unidades,						--6
		   v_codramo,						--7
		   v_desc_ramo,						--8
		   a_periodo,						--9
		   descr_cia,						--10
		   v_filtros,						--11
		   v_suma_asegurada / v_unidades,	    --12
		   v_suma_asegurada,				--13
		   _prima_ret_casco,				--14
		   _prima_cont,						--15
		   _sum_retencion,					--16
		   _sum_ret_casco,					--17
		   _suma_fac,						--18
		   _suma_fac_car,					--19
		   _sum_cont,  		--20
		   _prima_cobrada with resume;	
	let tot_cant = 0;
end foreach}

{
drop table temp_polizav;
--drop table temp_poliza;
drop table temp_perfil;
drop table temp_cant;
drop table temp_prima;
}

end procedure;