--------------------------------------------
--TOTALES DE DETALLE DE REASEGURO POR RAMO -
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro36
--- Modificado por Armando Moreno 19/01/2002; la parte de los tipo de contratos
--------------------------------------------

drop procedure sp_pro36;
create procedure "informix".sp_pro36(
a_compania		char(3),
a_agencia		char(3),
a_periodo1		char(7),
a_periodo2		char(7),
a_codsucursal	varchar(255)	default "*",
a_codgrupo		varchar(255)	default "*",
a_codagente		varchar(255)	default "*",
a_codusuario	varchar(255)	default "*",
a_codramo		varchar(255)	default "*",
a_reaseguro		varchar(255)	default "*")

returning	char(3),
			char(50),
			dec(16,2),
			dec(10,2),
			dec(10,2),
			dec(10,2),
			dec(10,2),
			dec(10,2),
			char(50),
			varchar(255);


begin

define _error_desc			varchar(255);
define v_filtros			varchar(255);
define v_desc_ramo			varchar(50);
define v_descr_cia			varchar(50);
define v_nopoliza			char(10);
define v_cod_contrato		char(5);
define v_noendoso			char(5);
define _cod_endomov			char(3);
define v_cobertura			char(3);
define v_cod_ramo			char(3);
define _tipo				char(1);
define v_prima_suscrita		dec(16,2);
define v_retencion			dec(16,2);
define v_facul_otros		dec(10,2);
define v_facul_terre		dec(10,2);
define v_comi_terre			dec(10,2);
define v_comi_otros			dec(10,2);
define v_prima				dec(10,2);
define v_tipo_contrato		smallint;
define sta_terremoto		smallint;
define _error				smallint;

call sp_pro34(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,a_codusuario,a_codramo,a_reaseguro)
returning v_filtros;

create temp table temp_reaseguro(
cod_ramo	char(3),
desc_ramo	varchar(50),
retencion	dec(16,2),
facul_terre	dec(10,2),
facul_otros	dec(10,2),
comi_terre	dec(10,2),
comi_otros	dec(10,2),
primary key(cod_ramo)) with no log;

create temp table temp_reaseguro1(
cod_ramo	char(3),
prima		dec(16,2),
primary key(cod_ramo)) with no log;

let v_prima_suscrita  = 0;
let v_descr_cia = sp_sis01(a_compania);

set isolation to dirty read;

foreach
	select no_poliza,
		   no_endoso,
		   sum(prima)
	  into v_nopoliza,
		   v_noendoso,
		   v_prima_suscrita
	  from temp_det 
	 where seleccionado = 1
	 group by 1, 2

	select cod_ramo
	  into v_cod_ramo
	  from emipomae
	 where no_poliza = v_nopoliza;

	begin
		on exception in(-239)
			update temp_reaseguro1
			   set prima    = prima + v_prima_suscrita
			 where cod_ramo = v_cod_ramo;
		end exception
		
		insert into temp_reaseguro1
		values(	v_cod_ramo,
				v_prima_suscrita);
	end

	select cod_endomov
	  into _cod_endomov
	  from endedmae
	 where no_poliza = v_nopoliza
	   and no_endoso = v_noendoso;

	drop table if exists tmp_reas;

	if _cod_endomov = '017' then --Cuando es un Endoso de Camb. de Reas. Indiv. debe usar emifacon porque la suma de las primas es 0. 08/04/2016
		select e.cod_cober_reas,
			   e.cod_contrato,
			   e.prima as prima_rea
		  from emifacon	e, endeduni r
		 where e.no_poliza = r.no_poliza
		   and e.no_endoso = r.no_endoso
		   and e.no_unidad = r.no_unidad
		   and e.no_poliza = v_nopoliza
		   and e.no_endoso = v_noendoso
		into temp tmp_reas;
	else
		call sp_sis122(v_nopoliza, v_noendoso) returning _error,_error_desc;
	end if

	foreach
		select cod_cober_reas,
    		   cod_contrato,
	    	   prima_rea
          into v_cobertura,
      	   	   v_cod_contrato,
      	   	   v_prima
          from tmp_reas
         where prima_rea <> 0
		
		{select e.cod_cober_reas,
			   e.cod_contrato,
			   e.prima
		  into v_cobertura,
			   v_cod_contrato,
			   v_prima
		  from emifacon	e, endeduni r
		 where e.no_poliza = r.no_poliza
		   and e.no_endoso = r.no_endoso
		   and e.no_unidad = r.no_unidad
		   and e.no_poliza = v_nopoliza
		   and e.no_endoso = v_noendoso}

		select tipo_contrato
		  into v_tipo_contrato
		  from reacomae
		 where cod_contrato = v_cod_contrato;

		let v_retencion   = 0;
		let v_facul_terre = 0;
		let v_facul_otros = 0;
		let v_comi_terre  = 0;
		let v_comi_otros  = 0;

		select es_terremoto
		  into sta_terremoto
		  from reacobre
		 where cod_cober_reas = v_cobertura;

		if v_tipo_contrato = 1 then	  --retencion
			let v_retencion = v_prima;
		elif v_tipo_contrato = 3 then --facult.
			if sta_terremoto = 1 then
				let v_facul_terre = v_prima;
			else
				let v_facul_otros = v_prima;
			end if			
		else
			if sta_terremoto = 1 then
				let v_comi_terre = v_prima;
			else
				let v_comi_otros = v_prima;
			end if
		end if

		begin
			on exception in(-239)
				update temp_reaseguro
				   set retencion     = retencion   + v_retencion,
					   facul_terre   = facul_terre + v_facul_terre,
					   facul_otros   = facul_otros + v_facul_otros,
					   comi_terre    = comi_terre  + v_comi_terre,
					   comi_otros    = comi_otros  + v_comi_otros
				 where cod_ramo      = v_cod_ramo;

			end exception
			
			select nombre
			  into v_desc_ramo
			  from prdramo
			 where cod_ramo = v_cod_ramo;

			insert into temp_reaseguro
			values(	v_cod_ramo,
					v_desc_ramo,
					v_retencion,
					v_facul_terre,
					v_facul_otros,
					v_comi_terre,
					v_comi_otros);
		end
	end foreach
end foreach

foreach
	select cod_ramo,
		   desc_ramo,
		   retencion,
		   facul_terre,
		   facul_otros,
		   comi_terre,
		   comi_otros
	  into v_cod_ramo,
		   v_desc_ramo,
		   v_retencion,
		   v_facul_terre,
		   v_facul_otros,
		   v_comi_terre,
		   v_comi_otros
	  from temp_reaseguro
	 order by cod_ramo

	select prima
	  into v_prima_suscrita
	  from temp_reaseguro1
	 where cod_ramo = v_cod_ramo;

	return	v_cod_ramo,
			v_desc_ramo,
			v_prima_suscrita,
			v_retencion,
			v_facul_terre,
			v_facul_otros,
			v_comi_terre,
			v_comi_otros,
			v_descr_cia,
			v_filtros with resume;
end foreach

--      drop table temp_reaseguro;
--      drop table temp_reaseguro1;
--      drop table temp_det;
end
end procedure;
