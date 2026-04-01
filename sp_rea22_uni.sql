--      TOTALES DE PRODUCCION PERFIL COMBINADO        --
----   Copia del sp_pr999 Federico Coronado
--execute procedure sp_rea22_uni('001','001','2017-07','2018-03',"*","*","*","*","001;","*","*","2017,2016,2015,2014,2013,2012,2011,2010,2009,2008;","*")
drop procedure sp_rea22_uni;
create procedure sp_rea22_uni(
a_compania		char(3),
a_agencia		char(3),
a_periodo1		char(7),
a_periodo2		char(7),
a_codsucursal	char(255) default "*",
a_codgrupo		char(255) default "*",
a_codagente		char(255) default "*",
a_codusuario	char(255) default "*",
a_codramo		char(255) default "*",
a_reaseguro		char(255) default "*",
a_contrato		char(255) default "*",
a_serie			char(255) default "*",
a_subramo		char(255) default "*")
returning	char(3),
			char(50),
			dec(16,2),
			dec(16,2),
			integer,
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			integer,
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			integer,
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			char(100),
			char(255),
			dec(16,2);  
begin

define v_filtros		varchar(255); 
define v_desc_ramo		varchar(50); 
define v_descr_cia		varchar(50);
define v_cobertura		char(3);  
define v_cod_ramo		char(3);  
define v_rango_inicial	dec(16,2);
define v_facultativo1	dec(16,2);
define v_facultativo2	dec(16,2);
define v_facultativo	dec(16,2);
define v_rango_final	dec(16,2);
define v_acumulada1		dec(16,2);
define v_acumulada2		dec(16,2);
define v_acumulada		dec(16,2);
define v_retenida1		dec(16,2);
define v_retenida2		dec(16,2);
define v_cobrada1		dec(16,2);
define v_cobrada2		dec(16,2);
define v_bouquet1		dec(16,2);
define v_bouquet2		dec(16,2);
define v_fac_car1		dec(16,2);
define v_retenida		dec(16,2);
define v_fac_car2		dec(16,2);
define v_cobrada		dec(16,2);
define v_bouquet		dec(16,2);
define v_fac_car		dec(16,2);
define v_otros1			dec(16,2);
define v_otros2			dec(16,2);
define v_otros			dec(16,2);
define v_suma_asegurada	dec(16,2);
define _cantidad1		integer;
define _cantidad2		integer;
define _cantidad		integer;
define v_return22a		smallint;
define v_return22b		smallint;	
define v_return22c		smallint;
define _valor			smallint;

--SET DEBUG FILE TO "sp_rea22.trc"; 
--trace on;

set isolation to dirty read;

create temp table tmp_tabla_rea(
		cod_ramo		 char(3),
		desc_ramo		 char(50),
        rango_inicial    dec(16,2),
        rango_final      dec(16,2),
        cant_polizas     integer  default 0,
        p_cobrada        dec(16,2) default 0,
        p_retenida       dec(16,2) default 0,
		p_bouquet        dec(16,2) default 0,
		p_facultativo    dec(16,2) default 0,
		p_otros		     dec(16,2) default 0,
		p_fac_car	     dec(16,2) default 0,
		p_acumulada      dec(16,2) default 0,
		cant_polizas1    integer  default 0,
        p_cobrada1       dec(16,2) default 0,
        p_retenida1      dec(16,2) default 0,
		p_bouquet1       dec(16,2) default 0,
		p_facultativo1   dec(16,2) default 0,
		p_otros1		 dec(16,2) default 0,
		p_fac_car1	     dec(16,2) default 0,
		p_acumulada1     dec(16,2) default 0,
		cant_polizas2    integer  default 0,
        p_cobrada2       dec(16,2) default 0,
        p_retenida2      dec(16,2) default 0,
		p_bouquet2       dec(16,2) default 0,
		p_facultativo2   dec(16,2) default 0,
		p_otros2		 dec(16,2) default 0,
		p_fac_car2	     dec(16,2) default 0,
		p_acumulada2     dec(16,2) default 0,
		p_filtro         char(255), 
		p_suma_asegurada dec(16,2),
		no_documento     char(20) default '',
        primary key (cod_ramo,rango_inicial,rango_final)) with no log;

--Prima Cobrada
call sp_rea22a_uni2v2(a_compania,a_agencia, a_periodo1, a_periodo2, a_codsucursal, a_codgrupo, a_codagente, a_codusuario, a_codramo, a_reaseguro, a_contrato, a_serie, a_subramo) returning v_return22a;--('001','001','2011-03','2011-03','*','*','*','*','001;','*','*','*','*')

--Siniestros Pagados
call sp_rea22b(a_compania, a_agencia, a_periodo1, a_periodo2, a_codsucursal, a_contrato, a_codramo, a_serie, a_subramo) returning v_return22b;

--Siniestros Pendientes
call sp_rea22c(a_compania, a_agencia, a_periodo1, a_periodo2, a_codsucursal, a_contrato, a_codramo, a_serie, a_subramo) returning v_return22c;

let v_descr_cia  = sp_sis01(a_compania);
--let v_filtros = a_serie;
let _valor = 0;

foreach
	select distinct cod_ramo,
		   desc_ramo,
		   p_filtro
	  into v_cod_ramo,
		   v_desc_ramo,
		   v_filtros
	  from tmp_tabla_rea

	--Insertar los rangos que no tienen información
	foreach
		select p.rango1,
			   p.rango2
		  into v_rango_inicial,
			   v_rango_final
		  from parinfra p
		  left join  tmp_tabla_rea t on t.cod_ramo = p.cod_ramo and p.rango1 = t.rango_inicial
		  where  p.cod_ramo = v_cod_ramo
			and t.cod_ramo is null

		insert into tmp_tabla_rea(
				cod_ramo,							
				desc_ramo,							
				rango_inicial,					
				rango_final,  					
				cant_polizas, 					
				p_cobrada,    					
				p_retenida,   					
				p_bouquet,    					
				p_facultativo,					
				p_otros,
				p_fac_car,
				p_acumulada,
				cant_polizas1, 					
				p_cobrada1,    					
				p_retenida1,   					
				p_bouquet1,    					
				p_facultativo1,					
				p_otros1,
				p_fac_car1,
				p_acumulada1,
				cant_polizas2,
				p_cobrada2,
				p_retenida2,
				p_bouquet2,
				p_facultativo2,
				p_otros2,
				p_fac_car2,
				p_acumulada2,
				p_filtro,
				p_suma_asegurada,
				no_documento)
		values(	v_cod_ramo, 
				v_desc_ramo, 
				v_rango_inicial, 
				v_rango_final, 
				0, 
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				0.00,
				'',
				0.00,
				'');
	end foreach
end foreach

foreach
	select cod_ramo,
		   desc_ramo,
		   rango_inicial,
		   rango_final,
		   cant_polizas,
		   p_cobrada,
		   p_retenida,
		   p_bouquet,
		   p_facultativo,
		   p_otros,
		   p_fac_car,
		   --p_acumulada, 
		   cant_polizas1,
		   p_cobrada1,
		   p_retenida1,
		   p_bouquet1,
		   p_facultativo1,
		   p_otros1,
		   p_fac_car1,
		   --p_acumulada1,
		   cant_polizas2,
		   p_cobrada2,
		   p_retenida2,
		   p_bouquet2,
		   p_facultativo2,
		   p_otros2,
		   p_fac_car2,
		   --p_acumulada2,
		   p_filtro,
		   p_suma_asegurada
	  into v_cod_ramo, 
		   v_desc_ramo,
		   v_rango_inicial,
		   v_rango_final,
		   _cantidad,
		   v_cobrada,
		   v_retenida,
		   v_bouquet,
		   v_facultativo,
		   v_otros,
		   v_fac_car,
		   --v_acumulada,
		   _cantidad1,
		   v_cobrada1,
		   v_retenida1,
		   v_bouquet1,
		   v_facultativo1,
		   v_otros1,
		   v_fac_car1,
		   --v_acumulada1,
		   _cantidad2,
		   v_cobrada2,
		   v_retenida2,
		   v_bouquet2,
		   v_facultativo2,
		   v_otros2,
		   v_fac_car2,
		   --v_acumulada2,
		   v_filtros,
		   v_suma_asegurada
	  from tmp_tabla_rea 
	 order by cod_ramo,rango_inicial

	if v_cod_ramo in ('001','003') then
		let v_desc_ramo = 'INCENDIO';
	elif v_cod_ramo in ('010','011','012','013','014','021','022') then
		let v_desc_ramo = 'RAMOS TECNICOS';
	elif v_cod_ramo in ('015','007') then
		let v_desc_ramo = 'RIESGOS VARIOS';
	end if

	if _valor = 0 then
		let v_acumulada  = v_cobrada;
		let v_acumulada1 = v_cobrada1;
		let v_acumulada2 = v_cobrada2;
	else
		let v_acumulada  = v_acumulada  + v_cobrada;
		let v_acumulada1 = v_acumulada1 + v_cobrada1;
		let v_acumulada2 = v_acumulada2 + v_cobrada2;
	end if

	let _valor = 1;

	return	v_cod_ramo, 
			v_desc_ramo, 
			v_rango_inicial,
			v_rango_final, 
			_cantidad, 
			v_cobrada, 
			v_retenida, 
			v_bouquet, 
			v_facultativo, 
			v_otros,
			v_fac_car,
			v_acumulada,
			_cantidad1, 
			v_cobrada1, 
			v_retenida1, 
			v_bouquet1, 		--16
			v_facultativo1, 
			v_otros1,
			v_fac_car1,
			v_acumulada1,
			_cantidad2, 
			v_cobrada2, 
			v_retenida2, 
			v_bouquet2, 
			v_facultativo2, 
			v_otros2,
			v_fac_car2,
			v_acumulada2, 
			v_descr_cia, 
			v_filtros,
			v_suma_asegurada with resume;
end foreach


drop table if exists tmp_tabla_rea;
drop table if exists temp_det;
drop table if exists tmp_ramos;
drop table if exists temp_produccion;
drop table if exists temp_fact;
drop table if exists tmp_sinis;
drop table if exists temp_ramos_rea;
drop table if exists tmp_ramos_rea;
drop table if exists tmp_contrato1;
drop table if exists tmp_sinis_rea;
drop table if exists tmp_contrato_rea;

end

end procedure;