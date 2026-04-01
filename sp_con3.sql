-- Procedure que genera las polizas para semusa

-- Creado    : 08/11/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_con3;

create procedure sp_con3() 

define _no_documento		char(20);
define _no_unidad   		char(5);
define _cedula				char(30);
define _nombre_asegurado	char(50);
define _suma_asegurada		dec(16,2);
define _prima_vida			dec(16,2);
define _prima_salud			dec(16,2);
define _fecha_nac			date;
define _fecha_ing			date;
define _sexo				char(1);

define _cod_agente			char(5);
define _no_poliza			char(10);
define _cod_asegurado		char(10);
define _cod_parentesco		char(3);
define _nombre_parentesco	char(50);
define _secuencia			smallint;
define _porcentaje			dec(5,2);

{
create table consem01(
no_documento	char(20),
no_unidad		char(5),
cedula			char(30),
nombre			char(50),
suma_asegurada	dec(16,2),
prima_vida		dec(16,2),
prima_salud		dec(16,2),
fecha_nac		date,
fecha_ing		date,
sexo			char(1)
);

create table consem02(
no_documento	char(20),
no_unidad		char(5),
secuencia		smallint,	
nombre			char(50),
parentesco		char(50),
sexo			char(1),
fecha_ing		date,
fecha_nac		date
);

create table consem03(
no_documento	char(20),
no_unidad		char(5),
secuencia		smallint,	
nombre			char(50),
parentesco		char(50),
porcentaje		dec(5,2)
);
}

set isolation to dirty read;

let _cod_agente = "00270";

delete from consem01;
delete from consem02;
delete from consem03;
 
foreach
 select p.no_documento
   into _no_documento
   from emipomae p, emipoagt a
  where p.cod_ramo    in("018", "016")
	and p.actualizado = 1
	and a.cod_agente  = _cod_agente
	and p.no_poliza   = a.no_poliza
--	and p.no_documento = "1803-00336-01"
  group by no_documento

	let _no_poliza = sp_sis21(_no_documento);

	foreach 
	 select no_unidad,
	        cod_asegurado,
			prima,
			prima_vida,
			suma_asegurada,
			fecha_emision
	   into _no_unidad,
	        _cod_asegurado,
			_prima_salud,
			_prima_vida,
			_suma_asegurada,
			_fecha_ing
	   from emipouni
	  where no_poliza = _no_poliza

		select cedula,
		       nombre,
			   fecha_aniversario,
			   sexo
		  into _cedula,
		       _nombre_asegurado,
			   _fecha_nac,
			   _sexo
		  from cliclien 
		 where cod_cliente = _cod_asegurado;

		insert into consem01
		values(
		_no_documento,
		_no_unidad,
		_cedula,
		_nombre_asegurado,
		_suma_asegurada,
		_prima_vida,
		_prima_salud,
		_fecha_nac,
		_fecha_ing,
		_sexo
		);

		-- Dependientes

		let _secuencia = 0;

		foreach
		 select cod_cliente,
				date_added,
				cod_parentesco
		   into _cod_asegurado,
		        _fecha_ing,
				_cod_parentesco
		   from emidepen
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad

			let _secuencia = _secuencia + 1;

			select nombre
			  into _nombre_parentesco
			  from emiparen
			 where cod_parentesco = _cod_parentesco;

			select nombre,
				   fecha_aniversario,
				   sexo
			  into _nombre_asegurado,
				   _fecha_nac,
				   _sexo
			  from cliclien 
			 where cod_cliente = _cod_asegurado;

			insert into consem02
			values(
			_no_documento,
			_no_unidad,
			_secuencia,
			_nombre_asegurado,
			_nombre_parentesco,
			_sexo,
			_fecha_ing,
			_fecha_nac
			);

		end foreach

		-- Beneficiarios

		let _secuencia = 0;

		foreach
		 select cod_cliente,
				cod_parentesco,
				porc_partic_ben
		   into _cod_asegurado,
		        _cod_parentesco,
				_porcentaje
		   from emibenef
		  where no_poliza = _no_poliza
		    and no_unidad = _no_unidad

			let _secuencia = _secuencia + 1;

			select nombre
			  into _nombre_parentesco
			  from emiparen
			 where cod_parentesco = _cod_parentesco;

			select nombre,
				   fecha_aniversario,
				   sexo
			  into _nombre_asegurado,
				   _fecha_nac,
				   _sexo
			  from cliclien 
			 where cod_cliente = _cod_asegurado;

			insert into consem03
			values(
			_no_documento,
			_no_unidad,
			_secuencia,
			_nombre_asegurado,
			_nombre_parentesco,
			_porcentaje
			);

		end foreach

	end foreach

end foreach
        
--drop table consem01; 
--drop table consem02; 
--drop table consem03; 

end procedure