--- Renovacion Automatica. Proceso de excepciones
--- Creado 02/03/2009 por Armando Moreno

drop procedure sp_pro316_old;

create procedure "informix".sp_pro316_old(a_poliza char(10), a_periodo char(7) default '*')
returning integer;

begin

define v_documento  	char(20);
define v_factura    	char(10);
define v_renovar    	smallint;
define v_cod_renovar 	smallint;
define v_cod_no_renovar char(3);
define _cod_ramo        char(3);
define _no_poliza       char(10);
define v_vigencia_inic  date;
define _vig_inic_ult    date;
define v_vigencia_fin   date;
define v_tipo       	char(3);
define v_saldo      	decimal(16,2);
define v_cant       	smallint;
define v_cantidad   	smallint;
define v_incurrido  	decimal(16,2);
define v_pagos      	decimal(16,2);
define v_tot_pagos  	decimal(16,2);
define _suma_asegurada	decimal(16,2);
define _perd_total  	smallint;
define _todas_perdida  	smallint;
define _cod_compania   	char(3);
define _codigo_agencia	char(3);
define _cod_sucursal   	char(3);
define _centro_costo   	char(3);
define _usuario      	char(8);
define _cnt			  	smallint;
define _cantidad	  	smallint;
define _cod_agente      char(5);
define _porc_partic  	decimal(5,2);
define _vig_final		date;
define _cod_tipoprod    char(3);
define _cod_grupo       char(5);
define _salir           smallint;
define _cod_subramo     char(3);
define _fecha           date;
define _cod_manzana     char(15);
define _cod_asegurado   char(10);
define _fecha_aniversario date;
define _edad            integer;
define _no_unidad       char(5);
define _activo          smallint;
define _cod_acreedor    char(5);
define _ano_auto        smallint;
define _cod_cobertura   char(5);
define _estatus         smallint;
define _prima_bruta     decimal(16,2);
define _diezporc	    decimal(16,2);
define _saldo           decimal(16,2);
define _renglon         smallint;
define _reg             integer;
define _error           smallint;
define _usu_cob         char(8);
define _porcentaje      integer;
define _declarativa     smallint;
define _gerarquia       smallint;
define _cod_formapag    char(3);
define _tipo_forma      smallint;
define _bandera         smallint;
define _usu_cob_f       char(8);
define _tipo_agente     char(1);
define _renueva         smallint;
define _sis_renglon		smallint;
define _bander          smallint;
define _cod_contr       char(10);
define _ano				smallint;
define _mes				smallint;
define _mes_char		char(2);
define _fecha_aa        date;
define _no_pagos        smallint;
define _flag_moro       smallint;
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE v_monto_60       DEC(16,2);
define v_monto_90       DEC(16,2);


--SET DEBUG FILE TO "sp_pro316.trc"; 
--TRACE ON;                                                                

let _error = sp_pro317();

set isolation to dirty read;

let _fecha           = current;
let v_pagos          = 0;
let v_incurrido      = 0;
let v_cantidad       = 0;
let v_saldo          = 0;
let v_renovar        = 0;
let v_cod_renovar    = 0;
let _salir 			 = 0;
let v_factura        = NULL;
let v_cod_no_renovar = NULL;
let _prima_bruta     = 0;
let _ano_auto        = 0;
let _porcentaje      = 10;
let _bandera         = 0;
let _renueva         = 1;
let _sis_renglon     = 12;
let _bander          = 0;
let _flag_moro       = 0;

let _ano = year(_fecha);
let _mes = month(_fecha);
if _mes < 10 then
	let _mes_char = "0" || _mes;
else
    let _mes_char = _mes;
end if

if a_periodo = '*' then
	let a_periodo = _ano || '-' || _mes_char;
end if

let _fecha_aa = sp_sis36(a_periodo);

select no_documento, 
	   no_factura,
       renovada, 
       no_renovar, 
       cod_no_renov,
       vigencia_inic, 
       vigencia_final, 
       saldo,
	   cod_compania,
	   cod_sucursal,
	   cod_ramo,
	   cod_tipoprod,
	   cod_grupo,
	   cod_subramo,
	   suma_asegurada,
	   prima_bruta,
	   declarativa
  into v_documento, 
 	   v_factura, 
 	   v_renovar, 
 	   v_cod_renovar,
       v_cod_no_renovar, 
       v_vigencia_inic, 
       v_vigencia_fin, 
       v_saldo,
	   _cod_compania,
	   _cod_sucursal,
	   _cod_ramo,
	   _cod_tipoprod,
	   _cod_grupo,
	   _cod_subramo,
	   _suma_asegurada,
	   _prima_bruta,
	   _declarativa
  from emipomae
 where no_poliza = a_poliza;

select centro_costo
  into _centro_costo
  from insagen
 where codigo_agencia  = _cod_sucursal
   and codigo_compania = _cod_compania;

 --******************************************************************************
 --Polizas de CAR y MONTAJE no se renuevan automatico, deben entrar en excepcion*
 --se incluye como excep al ramo de casco por inst. Vielka R. 29/04/2010
 --******************************************************************************

 if _cod_ramo in("014","013","017") then

  		let _usuario = sp_pro322(_centro_costo,'2',20);--polizas con ramo car o montaje

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo) VALUES (_usuario,a_poliza,20,'2');
	
 end if

-- Solicitud del 19/06/2013	Puesta en produccion 25/06/2013
-- Eliminacion de la Excepcion de Responsabilidad Civil
 
{												 /
 if _cod_ramo = "006" then	--Responsabilidad Civil Solicita Rosa Fung y Edicta 24/01/2011 q no pasen a automaticas, sino a excepciones para su verificacion previa

  		let _usuario = sp_pro322(_centro_costo,'2',50);--polizas con ramo resp. civil para su verificacion

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo) VALUES (_usuario,a_poliza,50,'2');
	
 end if
}

 if _cod_ramo = '008' then
	if _cod_subramo = "005" then
  		let _usuario = sp_pro322(_centro_costo,'6',18);--Fianzas de secuestro
  		let _gerarquia = sp_pro327(_centro_costo,'6',18,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,18,'6',_gerarquia);
		
	elif _cod_subramo = "022" then

  		let _usuario = sp_pro322(_centro_costo,'6',19);--Fianzas de levantamiento de secuestro
  		let _gerarquia = sp_pro327(_centro_costo,'6',19,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,19 ,'6',_gerarquia);

	elif _cod_subramo = "016" then

  		let _usuario = sp_pro322(_centro_costo,'6',36);--Fianzas de levantamiento de secuestro
  		let _gerarquia = sp_pro327(_centro_costo,'6',36,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,36 ,'6',_gerarquia);
			
	elif _cod_subramo = "018" then

  		let _usuario = sp_pro322(_centro_costo,'6',37);--Fianzas de levantamiento de secuestro
  		let _gerarquia = sp_pro327(_centro_costo,'6',37,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,37 ,'6',_gerarquia);

	elif _cod_subramo = "003" then

  		let _usuario = sp_pro322(_centro_costo,'6',38);--Fianzas de levantamiento de secuestro
  		let _gerarquia = sp_pro327(_centro_costo,'6',38,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,38 ,'6',_gerarquia);

	elif _cod_subramo = "004" then

  		let _usuario = sp_pro322(_centro_costo,'6',39);--Fianzas de levantamiento de secuestro
  		let _gerarquia = sp_pro327(_centro_costo,'6',39,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,39 ,'6',_gerarquia);

	elif _cod_subramo = "024" then

  		let _usuario = sp_pro322(_centro_costo,'6',40);--Fianzas de levantamiento de secuestro
  		let _gerarquia = sp_pro327(_centro_costo,'6',40,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,40 ,'6',_gerarquia);

	elif _cod_subramo = "020" then

  		let _usuario = sp_pro322(_centro_costo,'6',41);--Fianzas de levantamiento de secuestro
  		let _gerarquia = sp_pro327(_centro_costo,'6',41,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,41 ,'6',_gerarquia);

	elif _cod_subramo = "021" then

  		let _usuario = sp_pro322(_centro_costo,'6',42);--Fianzas de levantamiento de secuestro
  		let _gerarquia = sp_pro327(_centro_costo,'6',42,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,42 ,'6',_gerarquia);

	elif _cod_subramo = "025" then

  		let _usuario = sp_pro322(_centro_costo,'6',43);--Fianzas de levantamiento de secuestro
  		let _gerarquia = sp_pro327(_centro_costo,'6',43,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,43 ,'6',_gerarquia);


	elif _cod_subramo = "023" then

  		let _usuario = sp_pro322(_centro_costo,'6',44);--Fianzas de levantamiento de secuestro
  		let _gerarquia = sp_pro327(_centro_costo,'6',44,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,44 ,'6',_gerarquia);

	elif _cod_subramo = "001" then

  		let _usuario = sp_pro322(_centro_costo,'6',45);--Fianzas de levantamiento de secuestro
  		let _gerarquia = sp_pro327(_centro_costo,'6',45,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,45 ,'6',_gerarquia);

	end if

 end if

 --***********************
 --Excepciones de Tecnico*
 --***********************

  --polizas con facultativos
  select count(*)
    into _cnt
    from emifafac
   where no_poliza = a_poliza;

  if _cnt > 0 then
		if _cod_ramo in('002') then --AUTO
	  		let _usuario = sp_pro322(_centro_costo,'1',24);--polizas con facultativos
	  		let _gerarquia = sp_pro327(_centro_costo,'1',24,_usuario);
			INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,24,'1',_gerarquia);

	   	elif _cod_ramo in('008') then	  --FIANZAS

	  		let _usuario = sp_pro322(_centro_costo,'6',26);--polizas con facultativos
	  		let _gerarquia = sp_pro327(_centro_costo,'6',26,_usuario);
			INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,26,'6',_gerarquia);


		elif _cod_ramo in('016','018','019','004') then	 --PERSONAS

	  		let _usuario = sp_pro322(_centro_costo,'3',25);--polizas con facultativos
	  		let _gerarquia = sp_pro327(_centro_costo,'3',25,_usuario);
			INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,25,'3',_gerarquia);

		elif _cod_ramo in('020') then
		else											 --PATRIMONIALES

	  		let _usuario = sp_pro322(_centro_costo,'2',2);--polizas con facultativos
	  		let _gerarquia = sp_pro327(_centro_costo,'2',2,_usuario);
			INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,2,'2',_gerarquia);
			
		end if

  end if

	  --polizas con ubicacion zona libre y france field
  if _cod_ramo in('001','003') then

	  foreach

		  select cod_manzana
		    into _cod_manzana
			from emipouni
		   where no_poliza = a_poliza

		  if _cod_manzana[1,12] = '030010020103' or _cod_manzana[1,12] = '030010064400' then

		  		let _usuario = sp_pro322(_centro_costo,'2',1);--polizas con ubicacion zona libre - francefield
		  		let _gerarquia = sp_pro327(_centro_costo,'2',1,_usuario);

				INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,1,'2',_gerarquia);
				exit foreach;

		  end if

	  end foreach
  end if

  -- Polizas del ramo transporte
  if _cod_ramo = '009' then
	if _cod_subramo = "001" then --  subramo terrestre anual 001

-- Solicitud de Juan Silva del 19/06/2013.  Puesta en Produccion 25/06/2013.

--  		let _usuario = sp_pro322(_centro_costo,'2',46);
--  		let _gerarquia = sp_pro327(_centro_costo,'2',46,_usuario);

--		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,46,'2',_gerarquia);

	elif _cod_subramo = "002" then	 --subramo terrestre por carga 002

  		let _usuario = sp_pro322(_centro_costo,'2',47);
  		let _gerarquia = sp_pro327(_centro_costo,'2',47,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,47,'2',_gerarquia);

	end if
  end if

	  --polizas declarativas solo ramos incendio / transporte
  if _cod_ramo in('001','009') then
	  if _declarativa = 1 then
  		let _usuario = sp_pro322(_centro_costo,'2',21);
  		let _gerarquia = sp_pro327(_centro_costo,'2',21,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,21,'2',_gerarquia);
	  end if
  end if

	  --Polizas con Coaseguro

  if _cod_tipoprod in('001','002') then

		if _cod_ramo in('002') then --AUTO
	  		let _usuario = sp_pro322(_centro_costo,'1',27);
	  		let _gerarquia = sp_pro327(_centro_costo,'1',27,_usuario);
			INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,27,'1',_gerarquia);

	   	elif _cod_ramo in('008') then	  --FIANZAS

	  		let _usuario = sp_pro322(_centro_costo,'6',29);
	  		let _gerarquia = sp_pro327(_centro_costo,'6',29,_usuario);
			INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,29,'6',_gerarquia);


		elif _cod_ramo in('016','018','019','004') then	 --PERSONAS

	  		let _usuario = sp_pro322(_centro_costo,'3',28);
	  		let _gerarquia = sp_pro327(_centro_costo,'3',28,_usuario);
			INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,28,'3',_gerarquia);
		elif _cod_ramo in('020') then
		else											 --PATRIMONIALES

	  		let _usuario = sp_pro322(_centro_costo,'2',3);
	 		let _gerarquia = sp_pro327(_centro_costo,'2',3,_usuario);
			INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,3,'2',_gerarquia);
			
		end if

  end if

  --Polizas con Reclamos
  let v_cantidad = 0;

  select count(*) 
    into v_cantidad 
    from recrcmae
   where no_poliza   = a_poliza
     and actualizado = 1;

  if v_cantidad > 0 then

	if _cod_ramo in('002') then --AUTO
  		let _usuario = sp_pro322(_centro_costo,'1',30);
  		let _gerarquia = sp_pro327(_centro_costo,'1',30,_usuario);
		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,30,'1',_gerarquia);

   	elif _cod_ramo in('008') then	  --FIANZAS

  		let _usuario = sp_pro322(_centro_costo,'6',32);
  		let _gerarquia = sp_pro327(_centro_costo,'6',32,_usuario);
		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,32,'6',_gerarquia);


	elif _cod_ramo in('016','018','019','004') then	 --PERSONAS
	elif _cod_ramo in('020') then
	else											 --PATRIMONIALES

	  	let _usuario = sp_pro322(_centro_costo,'2',4);--polizas con reclamos
	  	let _gerarquia = sp_pro327(_centro_costo,'2',4,_usuario);
		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,4,'2',_gerarquia);

	end if

  end if

  if _cod_ramo = '004' then

	  --Polizas del Ramo Accidentes personales cuando el asegurado es > a 70 anos.

	  let v_cantidad = 0;

	  select count(*) 
	    into v_cantidad 
	    from recrcmae
	   where no_poliza   = a_poliza
	     and actualizado = 1;

	  if v_cantidad > 0 then
	  	let _usuario = sp_pro322(_centro_costo,'3',31);--polizas con reclamos
	  	let _gerarquia = sp_pro327(_centro_costo,'3',31,_usuario);
		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,31,'3',_gerarquia);
	  end if

	  let v_cantidad = 0;

	  select count(*)
	    into v_cantidad
	    from emipouni
	   where no_poliza = a_poliza;

	  if v_cantidad > 1 then

		  foreach

			select cod_asegurado
			  into _cod_asegurado
			  from emipouni
			 where no_poliza = a_poliza

			select fecha_aniversario
			  into _fecha_aniversario
			  from cliclien
			 where cod_cliente = _cod_asegurado;

			if _fecha_aniversario is null then
				continue foreach;
			end if

			let _edad = sp_sis78(_fecha_aniversario,_fecha);--Retorna la edad a la fecha

			if _edad > 70 then
				
		  		let _usuario   = sp_pro322(_centro_costo,'3',15);
		  		let _gerarquia = sp_pro327(_centro_costo,'3',15,_usuario);
				INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,15,'3',_gerarquia);
				exit foreach;

			end if

		  end foreach
	  else
			select cod_asegurado
			  into _cod_asegurado
			  from emipouni
			 where no_poliza = a_poliza;

			select fecha_aniversario
			  into _fecha_aniversario
			  from cliclien
			 where cod_cliente = _cod_asegurado;

			if _fecha_aniversario is not null then

				let _edad = sp_sis78(_fecha_aniversario,_fecha);--Retorna la edad a la fecha

				if _edad > 70 then
					
			  		let _usuario = sp_pro322(_centro_costo,'3',15);
			  		let _gerarquia = sp_pro327(_centro_costo,'3',15,_usuario);

					INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,15,'3',_gerarquia);
				end if
			end if
	  end if
  end if

  if _cod_ramo = '019' then

	  select count(*)
	    into _cnt
	    from emipouni
	   where no_poliza = a_poliza;

	  if _cnt > 1 then

		let _usuario = sp_pro322(_centro_costo,'3',5);--polizas colectivas
  		let _gerarquia = sp_pro327(_centro_costo,'3',5,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,5,'3',_gerarquia);

	  else

	   {	let _usuario = sp_pro322(_centro_costo,'3',6);--polizas individuales
  		let _gerarquia = sp_pro327(_centro_costo,'3',6,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,6,'3',_gerarquia);}

	  end if
  end if

  if _cod_ramo = '018' then
	
	  let v_cantidad = 0;
	  let _salir     = 0;

	  if _cod_subramo = '012' then --subramo colectivo

			let _usuario = sp_pro322(_centro_costo,'3',5);--polizas colectivas
	  		let _gerarquia = sp_pro327(_centro_costo,'3',5,_usuario);

			INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,5,'3',_gerarquia);

		  select count(*) 
		    into v_cantidad 
		    from recrcmae
		   where no_poliza   = a_poliza
		     and actualizado = 1;

		  if v_cantidad > 0 then
			
			let _usuario = sp_pro322(_centro_costo,'3',31);--polizas colectivas
	  		let _gerarquia = sp_pro327(_centro_costo,'3',31,_usuario);

			INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,31,'3',_gerarquia);

		  end if

	  end if

	  let v_cantidad = 0;

	  --Polizas del Ramo salud cuando por lo menos algun dependiente es > a 25 anos.
	  select count(*)
	    into _cnt
	    from emipouni
	   where no_poliza = a_poliza;

	  let a_poliza = a_poliza;	
	  foreach

		select cod_asegurado,
		       no_unidad
		  into _cod_asegurado,
		       _no_unidad
		  from emipouni
		 where no_poliza = a_poliza

		foreach

			select cod_cliente,
			       activo
			  into _cod_asegurado,
				   _activo
			  from emidepen
			 where no_poliza = a_poliza
			   and no_unidad = _no_unidad

			if _activo = 1 then

				select fecha_aniversario
				  into _fecha_aniversario
				  from cliclien
				 where cod_cliente = _cod_asegurado;

				if _fecha_aniversario is null then
					continue foreach;
				end if

				let _edad = sp_sis78(_fecha_aniversario,_fecha);--Retorna la edad a la fecha

				if _edad > 25 then
					
						if _cnt > 1 then

							let _usuario = sp_pro322(_centro_costo,'3',5);--polizas colectivas
					  		let _gerarquia = sp_pro327(_centro_costo,'3',5,_usuario);

							INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,16,'3',_gerarquia);
							exit foreach;
						else

							let _usuario = sp_pro322(_centro_costo,'3',6);--polizas individuales
					  		let _gerarquia = sp_pro327(_centro_costo,'3',6,_usuario);

							INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,16,'3',_gerarquia);
							exit foreach;

			    		end if
			    end if
		    end if
		end foreach
	  end foreach

	  --Polizas del Ramo salud cuando el grupo es <> a sin grupo 00001.

	  if _cod_grupo <> '00001' then

		  if _cnt > 1 then

				let _usuario = sp_pro322(_centro_costo,'3',5);--polizas colectivas
		  		let _gerarquia = sp_pro327(_centro_costo,'3',5,_usuario);

				INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,17,'3',_gerarquia);
		  else

				let _usuario = sp_pro322(_centro_costo,'3',6);--polizas individuales
		  		let _gerarquia = sp_pro327(_centro_costo,'3',6,_usuario);
				INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,17,'3',_gerarquia);
		  end if
	  end if
 end if

 if _cod_ramo = '016' then	--Ramo Colectivo de Vida

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = a_poliza
	  exit foreach;
	end foreach

    if _cod_subramo = '002' and _cod_grupo = '01016' and _cod_agente = '00180' then	--subramo industria, grupo sunctracs, tecnica de seg.
		INSERT INTO tmp_reaut(usuario,no_poliza) VALUES ('AUTOMATI',a_poliza);
		return 0;
	else

		let _usuario = sp_pro322(_centro_costo,'3',5);--polizas colectivas
		let _gerarquia = sp_pro327(_centro_costo,'3',5,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,5,'3',_gerarquia);

	    let v_cantidad = 0;

	    select count(*) 
	      into v_cantidad 
	      from recrcmae
	     where no_poliza   = a_poliza
	       and actualizado = 1;

	  	if v_cantidad > 0 then

			let _usuario = sp_pro322(_centro_costo,'3',31);--polizas colectivas
			let _gerarquia = sp_pro327(_centro_costo,'3',31,_usuario);

			INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,31,'3',_gerarquia);

		end if
	end if

 end if

{ if _cod_ramo = '020' then	--Ramo SODA

	let _usuario = sp_pro322(_centro_costo,'1',0);--polizas del ramo SODA
	let _gerarquia = sp_pro327(_centro_costo,'1',0,_usuario);

	INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,0,'1',_gerarquia);

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = a_poliza

		if _cod_agente = '00035' then --CORREDOR DUCRUET

			let _usuario = sp_pro322(_centro_costo,'5',33);
			let _gerarquia = sp_pro327(_centro_costo,'5',33,_usuario);

			INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,33,'5',_gerarquia);
			exit foreach;
		end if

	end foreach

 end if}

 if _cod_ramo = '002' then	--Ramo AUTOMOVIL

	  select count(*)
	   into v_cantidad
	   from emipouni
	  where no_poliza = a_poliza;

	  if v_cantidad > 1 then	-- Es Flota

		let _usuario = sp_pro322(_centro_costo,'1',7);--Flota del ramo AUTOMOVIL
  		let _gerarquia = sp_pro327(_centro_costo,'1',7,_usuario);

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,7,'1',_gerarquia);

	  elif  v_cantidad = 0 then
		  return 0;
	  else
			--
			foreach
				select cod_agente
				  into _cod_agente
				  from emipoagt
				 where no_poliza = a_poliza

				if _cod_agente in('00180','00161') then --TECNICA DE SEGUROS  /  GENERAL REPRESENTATIVES

					let _usuario = sp_pro322(_centro_costo,'5',8);-- ramo AUTOMOVIL con corredor
			  		let _gerarquia = sp_pro327(_centro_costo,'5',8,_usuario);

					INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,8,'5',_gerarquia);
					exit foreach;

				elif _cod_agente = "00628" then

				   {	let _usuario = sp_pro322(_centro_costo,'5',35);-- ramo AUTOMOVIL con corredor IVETTE BERNAL
			  		let _gerarquia = sp_pro327(_centro_costo,'5',35,_usuario);

					INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,35,'5',_gerarquia);
					exit foreach; }--se desactiva 06/02/2012 por intr. de Analisa segun solicitud escrita de fecha 31/01/2012

				end if

			end foreach

			--Polizas con Acreedor INSTACASH
			foreach
				select cod_acreedor
				  into _cod_acreedor
				  from emipoacr
				 where no_poliza = a_poliza

				if _cod_acreedor = '01913' then --INSTACASH

					let _usuario = sp_pro322(_centro_costo,'5',9);--Flota del ramo AUTOMOVIL con acreedor
		     		let _gerarquia = sp_pro327(_centro_costo,'5',9,_usuario);

					INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,9,'5',_gerarquia);
					exit foreach;
				end if

			end foreach

			--Subramo Particular y el auto tiene 10 anos.
			--o suma asegurada menor a 4000

			select COUNT(*)
			  into _cnt
			  from emipoacr
			 where no_poliza = a_poliza;

			if _cod_subramo = '001' then
				  foreach

					select ano_tarifa
					  into _ano_auto
					  from emiauto
					 where no_poliza = a_poliza
					exit foreach;
				  end foreach

				  if _ano_auto is null then
					let _ano_auto = 0;
				  end if
				  let _usuario = sp_pro322(_centro_costo,'1',10);--Polizas del ramo AUTOMOVIL subramo x
	    		  let _gerarquia = sp_pro327(_centro_costo,'1',10,_usuario);

				  let _bandera = 0;

				  select count(*)
				    into _bandera
				    from emipocob
				   where no_poliza = a_poliza
				     and cod_cobertura in("00606","00118","00119","00121","00120","00902","00103","00901");

				  if _ano_auto >= 10 and _bandera > 0 then
						INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,10,'1',_gerarquia);
				  end if

				  if (_suma_asegurada < 4000) and (_bandera > 0) then

						INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,22,'1',_gerarquia);

				  end if

				if _cnt > 0 and _suma_asegurada < 3500 then	--tiene aceedor y suma menor a 3500

				  let _usuario = sp_pro322(_centro_costo,'1',60);--Polizas del ramo AUTOMOVIL subramo x
	    		  let _gerarquia = sp_pro327(_centro_costo,'1',60,_usuario);
				  INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,60,'1',_gerarquia);	

				end if
			elif _cod_subramo = '002' and _suma_asegurada < 3500 and _cnt > 0 then  --Subramo Comercial y suma menoar a 3500  con acreedor

			    let _usuario = sp_pro322(_centro_costo,'1',59);
		  		let _gerarquia = sp_pro327(_centro_costo,'1',59,_usuario);

				INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,59,'1',_gerarquia);
							
			end if

			foreach
					select no_unidad
					  into _no_unidad
					  from emipouni
					 where no_poliza = a_poliza

					exit foreach;
			end foreach

			foreach
					select cod_cobertura
					  into _cod_cobertura
					  from emipocob
					 where no_poliza = a_poliza
					   and no_unidad = _no_unidad

					if _cod_cobertura in('00119','00121','00606','00118','00120','00902','00103','00901') then
						foreach
							select ano_tarifa
							  into _ano_auto
							  from emiauto
							 where no_poliza = a_poliza
							exit foreach;
					    end foreach

					    if _ano_auto is null then
							let _ano_auto = 0;
						end if

						if _ano_auto > 15 then

						    let _usuario = sp_pro322(_centro_costo,'1',10);--Polizas del ramo AUTOMOVIL subramo x
					  		let _gerarquia = sp_pro327(_centro_costo,'1',10,_usuario);

							INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,23,'1',_gerarquia);
							exit foreach;
						end if
					end if

					if _cod_cobertura in('00119','00121','00606','00118','00120','00902','00103','00901') then
						foreach
							select ano_tarifa
							  into _ano_auto
							  from emiauto
							 where no_poliza = a_poliza
							exit foreach;
					    end foreach

					    if _ano_auto is null then
						  let _ano_auto = 0;
					    end if

						if _ano_auto > 10 then

						    let _usuario = sp_pro322(_centro_costo,'1',10);--Polizas del ramo AUTOMOVIL subramo x
					  		let _gerarquia = sp_pro327(_centro_costo,'1',10,_usuario);

							INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,10,'1',_gerarquia);

						end if

						if _cod_subramo = '002' and _suma_asegurada < 3500 then  --Subramo Comercial y suma menoar a 3500

						    let _usuario = sp_pro322(_centro_costo,'1',34);
					  		let _gerarquia = sp_pro327(_centro_costo,'1',34,_usuario);

							INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,34,'1',_gerarquia);
							
						end if

					end if

			end foreach

		   {	foreach
				select cod_agente
				  into _cod_agente
				  from emipoagt
				 where no_poliza = a_poliza

				if _cod_agente = '00035' then --CORREDOR DUCRUET

					let _usuario = sp_pro322(_centro_costo,'5',33);
			  		let _gerarquia = sp_pro327(_centro_costo,'5',33,_usuario);

					INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo,gerarquia) VALUES (_usuario,a_poliza,33,'5',_gerarquia);
					exit foreach;
				end if

			end foreach}

	  end if
 end if


 --***********************
 --Excepcion de Cobros	 *
 --***********************

if _cod_ramo <> "019" then	--Si es Vida Individual no debe tener excepcion de cobros. segun sol. de Georgina 26/12/2012

	select cod_formapag,cod_contratante,no_pagos
	  into _cod_formapag,_cod_contr,_no_pagos
	  from emipomae
	 where no_poliza = a_poliza;

	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	let _diezporc = 0;
	let _saldo = sp_cob115b('001','001',v_documento,'');

	let _flag_moro = 0;
	if _no_pagos   = 12 then

		call sp_cob33('001','001', v_documento, a_periodo, _fecha_aa)
		     returning v_por_vencer,    
		               v_exigible,      
		               v_corriente,    
		               v_monto_30,      
		               v_monto_60,      
		               v_monto_90,
		               _saldo;   
		if v_monto_90 = 0 then --No tiene moro a mas de 90 dias
			let _flag_moro = 1;
		end if
	end if

	if _tipo_forma = 2 or _tipo_forma = 3 or _tipo_forma = 4 then	--2=visa,3=desc salario,4=ach

		select usuario_cobros,
		       saldo_elect,
			   usuario_cobro_f
		  into _usu_cob,
		       _porcentaje,
			   _usu_cob_f
		  from emirepar;

	else
		
		select usuario_cobros,
		       saldo_porc,
			   usuario_cobro_f
		  into _usu_cob,
		       _porcentaje,
			   _usu_cob_f
		  from emirepar;

	end if

	if _cod_ramo = "002" then
		foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = a_poliza

			if _cod_agente = "00161" then  --General Representatives es 25%	Armando 17//05/2011 Aut. por Leticia Escobar.
				let _porcentaje = 25;
				exit foreach;
			end if

			if _cod_agente = "00218" then  --Kam Panama
				exit foreach;
			end if

		end foreach

		let _bander = 0;
		select count(*)
		  into _bander
		  from emipouni
		 where no_poliza     = a_poliza
		   and cod_asegurado = "84250";  --Pacific Leasing

		if _bander > 0 or _cod_contr = "84250" then
			if _cod_agente = "00218" then  --Es Pacific Leasing y corredor Kam Panama, porc debe ser 20% sol. por Nixia Morales 29/09/2011, Armando.
				let _porcentaje = 20;
			end if
		end if

	end if

	let _diezporc = _prima_bruta * (_porcentaje / 100);
	let _usu_cob = trim(_usu_cob);

	if _cod_ramo = "020" and _saldo = 0 then
	else
		if _cod_ramo = "020" then
		    if _flag_moro = 0 then
				INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo) VALUES (_usu_cob,a_poliza,11,'4');
			end if
		else

			if _saldo > _diezporc then
				if (_cod_ramo = "008") and (_cod_subramo = "005" or _cod_subramo = "022") then --fianzas de sec y levantamiento de sec no se le pone excepcion de saldo.
				else
					if _cod_ramo = "008" then
						let _usu_cob = _usu_cob_f;
					end if
					if _flag_moro = 0 then
						INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo) VALUES (_usu_cob,a_poliza,11,'4');
					end if
				end if
			end if
		end if
	end if
end if
 --***********************
 --Excepciones de Sistema*
 --***********************
  if _cod_ramo <> "020" then
	  --Poliza con Notas
	  select count(*)
	    into v_cantidad
	    from eminotas
	   where no_documento = v_documento
	     and procesado = 0;

	  if v_cantidad > 0 then
	     if _cod_ramo in("001","003","010","011") then
			 let _usuario = sp_pro322(_centro_costo,'5',51);
			 let _gerarquia = sp_pro327(_centro_costo,'5',51,_usuario);
			 let _sis_renglon = 51;
	     elif _cod_ramo in("005","006","007","009","015","004","017") then
			 let _usuario = sp_pro322(_centro_costo,'5',52);
			 let _gerarquia = sp_pro327(_centro_costo,'5',52,_usuario);
			 let _sis_renglon = 52;
		 else
			 let _usuario = sp_pro322(_centro_costo,'5',12);
			 let _gerarquia = sp_pro327(_centro_costo,'5',12,_usuario);
			 let _sis_renglon = 12;
		 end if

	  	 --INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo) VALUES (_usuario,a_poliza,12,'5');
		   INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo) VALUES (_usuario,a_poliza,_sis_renglon,'5');
	  end if

	  --Polizas con Endoso descriptivo 015
	 select count(*)
	   into v_cantidad
	   from endedmae
	  where no_poliza   = a_poliza
	    and actualizado = 1
	    and cod_endomov = '015';

	 if v_cantidad > 0 then

		if _cod_ramo in("001","003","010","011") then
		 let _usuario = sp_pro322(_centro_costo,'5',53);
		 let _gerarquia = sp_pro327(_centro_costo,'5',53,_usuario);
		 let _sis_renglon = 53;
		elif _cod_ramo in("005","006","007","009","015","004","017") then
		 let _usuario = sp_pro322(_centro_costo,'5',54);
		 let _gerarquia = sp_pro327(_centro_costo,'5',54,_usuario);
		 let _sis_renglon = 54;
		else
		 if _cod_ramo = '002' then
		 else
			 let _usuario = sp_pro322(_centro_costo,'5',13);
			 let _gerarquia = sp_pro327(_centro_costo,'5',13,_usuario);
			 let _sis_renglon = 13;
		 end if
		end if
		if _cod_ramo <> '002' then
			INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo) VALUES (_usuario,a_poliza,_sis_renglon,'5');
		end if

	 end if

	  --Polizas con Endoso Modificacion 006
	 select count(*)
	   into v_cantidad
	   from endedmae
	  where no_poliza   = a_poliza
	    and actualizado = 1
	    and cod_endomov = '006';

	 if v_cantidad > 0 then

		if _cod_ramo in("001","003","010","011") then	--Esto se coloco para expandir la excepcion de sistemas a otros usuarios intr. Edicta 01/03/2011
		 let _usuario = sp_pro322(_centro_costo,'5',55);
		 let _gerarquia = sp_pro327(_centro_costo,'5',55,_usuario);
		 let _sis_renglon = 55;
		elif _cod_ramo in("005","006","007","009","015","004","017") then
		 let _usuario = sp_pro322(_centro_costo,'5',56);
		 let _gerarquia = sp_pro327(_centro_costo,'5',56,_usuario);
		 let _sis_renglon = 56;
		else
		 let _usuario = sp_pro322(_centro_costo,'5',14);
		 let _gerarquia = sp_pro327(_centro_costo,'5',14,_usuario);
		 let _sis_renglon = 14;
		end if

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo) VALUES (_usuario,a_poliza,_sis_renglon,'5');
	 end if
		  --Polizas con Endoso Inclusion 004 puesto en prod 25/06/2013 Armando
	 select count(*)
	   into v_cantidad
	   from endedmae
	  where no_poliza   = a_poliza
	    and actualizado = 1
	    and cod_endomov = '004';

	 if v_cantidad > 0 then

		 let _usuario = sp_pro322(_centro_costo,'5',61);
		 let _gerarquia = sp_pro327(_centro_costo,'5',61,_usuario);
		 let _sis_renglon = 61;

		INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo) VALUES (_usuario,a_poliza,_sis_renglon,'5');

	 end if


	 --Poliza con corredor directo especial 10/08/2010
	 let _renueva = 1;
	 foreach

		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = a_poliza

		select tipo_agente,renueva
		  into _tipo_agente,_renueva
		  from agtagent
		 where cod_agente = _cod_agente;

		if _tipo_agente = 'E' and _renueva = 0 then

			if _cod_ramo in("001","003","010","011") then	--Esto se coloco para expandir la excepcion de sistemas a otros usuarios intr. Edicta 01/03/2011
			 let _usuario = sp_pro322(_centro_costo,'5',57);
			 let _gerarquia = sp_pro327(_centro_costo,'5',57,_usuario);
			 let _sis_renglon = 57;
			elif _cod_ramo in("005","006","007","009","015","004","017") then
			 let _usuario = sp_pro322(_centro_costo,'5',58);
			 let _gerarquia = sp_pro327(_centro_costo,'5',58,_usuario);
			 let _sis_renglon = 58;
			else
				if _cod_ramo = '002' then
				else
				 let _usuario = sp_pro322(_centro_costo,'5',48);
				 let _gerarquia = sp_pro327(_centro_costo,'5',48,_usuario);
				 let _sis_renglon = 48;
				end if
			end if
			if _cod_ramo <> '002' then
				INSERT INTO tmp_reaut(usuario,no_poliza,renglon,tipo_ramo) VALUES (_usuario,a_poliza,_sis_renglon,'5');
			end if		   	
		end if
	 end foreach
  end if
 --***********************
 --Renovacion Automatica *
 --***********************
  select count(*)
   into v_cantidad
   from tmp_reaut
  where no_poliza = a_poliza;

  if v_cantidad > 0 then
  else
	INSERT INTO tmp_reaut(usuario,no_poliza) VALUES ('AUTOMATI',a_poliza);
  end if

end
return 0;

end procedure;
