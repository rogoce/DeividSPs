-- Procedimiento para cargar los clientes de contingencia local
-- Creado    : 17/05/2019 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cargar_cliente;
CREATE PROCEDURE sp_cargar_cliente()
RETURNING CHAR(10),
          char(3),     
          char(3),
          varchar(100),
          varchar(100),
          varchar(50),
          varchar(50),
          char(20),
          char(1),
          varchar(30),
          varchar(10),
          varchar(10),
          varchar(50),
          date,
          char(1),
          char(40),
          char(40),
          char(40),
          char(40),
          char(40),
          smallint;
		  
define _cod_asegurado_d     char(10);
define _cod_contratante     char(10);
define _cod_asegurado       char(10);
DEFINE v_cod_cliente  		CHAR(10);
define v_cod_compania       char(3);     
DEFINE v_cod_sucursal       char(3);
define v_nombre             varchar(100);
define v_nombre_razon       varchar(100);
define v_direccion_1        varchar(50);
define v_direccion_2        varchar(50);
define v_apartado           char(20);
DEFINE v_tipo_persona       char(1);
define v_cedula             varchar(30);
define v_telefono1          varchar(10);
define v_telefono2          varchar(10);
define v_e_mail             varchar(50);
DEFINE v_fecha_aniversario  date;
define v_sexo               char(1);
define v_aseg_primer_nom    char(40);
define v_aseg_segundo_nom   char(40);
define v_aseg_primer_ape    char(40);
DEFINE v_aseg_segundo_ape   char(40);
define v_aseg_casada_ape    char(40);
define v_pasaporte          smallint;



--SET DEBUG FILE TO "sp_pro67.trc"; 
--trace on;

SET ISOLATION TO DIRTY READ;

--SACAR INFORMACION DE LA POLIZA
create temp table tmp_cliente(
no_cliente		char(10)
) with no log;

FOREACH
	 select cod_contratante
	   into _cod_contratante
	   from emipomae
      where cod_ramo in('018','004') and estatus_poliza = 1
	  
	  insert into tmp_cliente(no_cliente)
	       values (_cod_contratante);
end foreach

FOREACH
	select emipouni.cod_asegurado
	  into _cod_asegurado
	  from emipomae inner join emipouni on emipomae.no_poliza = emipouni.no_poliza
     where emipomae.cod_ramo in('018','004') and estatus_poliza = 1
	  
	  insert into tmp_cliente(no_cliente)
	       values (_cod_asegurado);
end foreach

FOREACH
	select distinct(emidepen.cod_cliente)
	  into _cod_asegurado_d
      from emipomae inner join emidepen on emidepen.no_poliza = emipomae.no_poliza
     where emipomae.cod_ramo in('018','004') and estatus_poliza = 1
	  
	  insert into tmp_cliente(no_cliente)
	       values (_cod_asegurado_d);
end foreach

FOREACH
   select distinct(no_cliente)
	 into v_cod_cliente
     from tmp_cliente
	 where no_cliente is not null

  select cod_cliente,
         cod_compania,
		 cod_sucursal, 
		 nombre,
		 nombre_razon,
		 direccion_1, 
		 direccion_2,
		 apartado,
		 tipo_persona,
		 cedula,
		 telefono1,
		 telefono2,
		 e_mail,
		 fecha_aniversario,
		 sexo,
		 aseg_primer_nom,
		 aseg_segundo_nom,
		 aseg_primer_ape,
		 aseg_segundo_ape,
		 aseg_casada_ape,
		 pasaporte
    into v_cod_cliente,
	     v_cod_compania,
		 v_cod_sucursal,
		 v_nombre,
		 v_nombre_razon,
		 v_direccion_1, 
		 v_direccion_2,
		 v_apartado,
		 v_tipo_persona,
		 v_cedula,
		 v_telefono1,
		 v_telefono2,
		 v_e_mail,
		 v_fecha_aniversario,
		 v_sexo,
		 v_aseg_primer_nom,
		 v_aseg_segundo_nom,
		 v_aseg_primer_ape,
		 v_aseg_segundo_ape,
		 v_aseg_casada_ape,
		 v_pasaporte
    from cliclien
   where cod_cliente = v_cod_cliente;

	RETURN v_cod_cliente,
	       v_cod_compania,
	       v_cod_sucursal,
	       v_nombre,
	       v_nombre_razon,
	       v_direccion_1, 
	       v_direccion_2,
	       v_apartado,
	       v_tipo_persona,
	       v_cedula,
	       v_telefono1,
	       v_telefono2,
	       v_e_mail,
	       v_fecha_aniversario,
	       v_sexo,
	       v_aseg_primer_nom,
	       v_aseg_segundo_nom,
	       v_aseg_primer_ape,
	       v_aseg_segundo_ape,
	       v_aseg_casada_ape,
	       v_pasaporte
			WITH RESUME;
END FOREACH
drop table tmp_cliente;
END PROCEDURE 