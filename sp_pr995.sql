-- Pase de Borderaux a Estado de Cuenta
-- execute procedure sp_pr995("2009-2010",2,"03/03/2010")
-- Creado por Henry Giron
-- Fecha 13/11/2009
--sp_pr127("001","001",_per_1,_per_3,"*","*","*","*","001,003,006,008,010,011,012,013,014,021,022;","*","*","2012,2011,2010,2009,2008;")

drop procedure sp_pr995;
create procedure sp_pr995(
a_anio			char(9),
a_trimestre		smallint,
a_fecha			date,
a_anio2			char(9),
a_trimestre2	smallint,
a_actjul		integer,
a_actene		integer)

returning	integer,
			char(50);

define s_des_cod_clase	varchar(255);
define c_cod_ramo		varchar(10);
define s_cod_contrato	varchar(5);
define s_cod_clase		varchar(3);
define _edescrip		char(100);
define _desc_contrato	char(50);
define _error_desc		char(50);
define _eusuario		char(15);
define _dcuenta			char(12);
define _dno_recibo		char(10);
define _eno_remesa		char(10);
define _anio_reas		char(9);
define _ecomprobante	char(8);
define _eperiodo		char(7);
define _per_3			char(7);
define _per_1			char(7);
define _ecod_compania	char(3);
define _dcod_compania	char(3);
define _dcod_sucursal	char(3);
define s_cod_coasegur	char(3);
define _dcod_coasegur	char(3);
define _ecod_sucursal	char(3);
define _ecod_coasegur	char(3);
define _ecod_banco		char(3);
define _econcepto		char(3);
define _dcod_ramo		char(3);
define _eccosto			char(3);
define _dccosto			char(3);
define _dcod_contrato	char(2);
define _ecod_contrato	char(2);
define _borderaux		char(2); 
define _contrato		char(2);
define _emoneda			char(2);
define _dtipo			char(2);
define _etipo			char(2);
define s_p_partic		dec(16,2);
define s_credito		dec(16,2);
define _ecredito		dec(16,2);
define _dcredito		dec(16,2);
define s_debito			dec(16,2);
define _edebito			dec(16,2);
define _ddebito			dec(16,2);
define _emonto			dec(16,2);
define _esac_asientos	smallint;
define _eactualizado	smallint;
define _dactualizado	smallint;
define _dno_remesa		smallint;
define _trim_reas		smallint;
define _drenglon		smallint;
define s_renglon		smallint;
define s_existe			smallint;
define _eexiste			smallint;
define _existe			smallint;
define _error			integer;
define _efecha			date;
define _dfecha			date;

begin
set isolation to dirty read;  

let _existe = 0;
	
select periodo1,
       periodo3
  into _per_1,
       _per_3
  from reatrim
 where ano       = a_anio
   and trimestre = a_trimestre;

--BACKUP DE LAS TABLAS DE ESTADO DE CTA.ANTES DE LA ACTUALIZACION DE LOS BORDERAUX.

if a_actjul = 1 then
	delete from reaestct1bk
	 where ano       = a_anio
	   and trimestre = a_trimestre;

	delete from reaestct2bk
	 where ano       = a_anio
	   and trimestre = a_trimestre;

	insert into reaestct1bk 
	select * from reaestct1
	 where ano       = a_anio
	   and trimestre = a_trimestre;

	insert into reaestct2bk 
	select * from reaestct2
	 where ano       = a_anio
	   and trimestre = a_trimestre;
end if

if a_actene = 1 then
	delete from reaestct1bk
	 where ano       = a_anio2
	   and trimestre = a_trimestre2;

	delete from reaestct2bk
	 where ano       = a_anio2
	   and trimestre = a_trimestre2;

	insert into reaestct1bk 
	select * from reaestct1
	 where ano       = a_anio2
	   and trimestre = a_trimestre2;

	insert into reaestct2bk 
	select * from reaestct2
	 where ano       = a_anio2
	   and trimestre = a_trimestre2;
end if

if a_actjul = 1 then --TRIMESTRE COMIENZA EN JULIO
	foreach 
		select cod_contrato,nombre 
		  into _contrato,_desc_contrato 
		  from reacontr 
		 where activo = 1
		   and tipo   = 1

		let _existe = 0;

		select count(*) 
		  into _existe 
		  from reaestct1 
		 where ano       = a_anio 
		   and trimestre = a_trimestre 
		   and contrato  = _contrato;   -- Debe existir encabezado 

		if _existe = 0 then 
			foreach
				select distinct cod_coasegur
				  into s_cod_coasegur
				 from reacoest
				 where anio      = a_anio
				   and trimestre = a_trimestre
				   and borderaux = _contrato

				-- primer saldo en cero
				insert into reaestct1(
				ano,   
				trimestre,   
				reasegurador,   
				contrato,   
				saldo_inicial,   
				saldo_final,
				saldo_trim)
				values(
				a_anio,   
				a_trimestre,   
				s_cod_coasegur,   
				_contrato,   
				0,   
				0,
				0);
			end foreach
			delete from reaestct2 where ano = a_anio and trimestre = a_trimestre and contrato = _contrato;  -- elimina detalle
		end if
	end foreach
	foreach 
		select cod_contrato,
			   nombre
		  into _contrato,
			   _desc_contrato
		  from reacontr
		 where activo = 1
		   and tipo   = 1
		 order by 1

		let s_renglon  = 0;
		let s_debito   = 0;
		let s_credito  = 0;
		let _borderaux = _contrato;

		-- Participacion de Reaseguro
		-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%, 3-Terremoto(001,003)30%, 4-Ramos Tecnicos(010,011,012,014),
		-- 5-Fianzas(008,080), 6-Acc. Personales(004), 7-Vida Ind/Col(016,019)]					 
		foreach
			select reacoest.cod_coasegur,
				   reacoest.cod_clase,
				   reacoest.cod_contrato,
				   sum(reacoest.participar)
			  into s_cod_coasegur, 
				   s_cod_clase, 
				   s_cod_contrato, 
				   s_credito
			  from reacoest
			 where anio      = a_anio
			   and trimestre = a_trimestre
			   and borderaux = _borderaux 
			 group by reacoest.cod_coasegur,
				   reacoest.cod_clase,
				   reacoest.cod_contrato
			 order by reacoest.cod_coasegur,
				   reacoest.cod_clase,
				   reacoest.cod_contrato

			let s_debito = 0;

			if s_debito is null then
				let s_debito = 0 ;
			end if
			if s_credito is null then
				let s_credito =	0 ;
			end if

			select max(renglon)
			  into s_renglon
			  from reaestct2
			 where ano = a_anio
			   and trimestre    = a_trimestre
			   and contrato     = _borderaux 
			   and reasegurador = s_cod_coasegur;

			if s_renglon is null then
				let s_renglon =	0 ;
			end if

			let s_renglon =	s_renglon + 1;

			if s_cod_contrato is null then
				let s_cod_contrato =	"";
			end if

			if s_cod_clase = 'INI' or s_cod_clase = 'MUI' then
				let s_cod_clase = "002";
			end if

			if s_cod_clase = 'INT' or s_cod_clase = 'MUT' then
				let s_cod_clase = "003";
			end if

			select nombre
			  into s_des_cod_clase
			  from rearamo
			 where ramo_reas = s_cod_clase;
	
			if s_cod_clase = '001' or s_cod_clase = '006' or s_cod_clase = '007' or s_cod_clase = '012' then 
			   let s_des_cod_clase = trim(s_des_cod_clase)||" - Cuota Parte Serie "||trim(s_cod_contrato);
			else 
			   let s_des_cod_clase = trim(s_des_cod_clase)||" - Excedente Serie "||trim(s_cod_contrato);
			end if 

			if s_credito < 0 then 
			   let s_debito  = -1 * s_credito;
			   let s_credito =	0;
			end if 

			insert into reaestct2 (ano,trimestre,reasegurador,contrato,renglon,concepto1,concepto2,debe,haber,ramo_reas)
			values (a_anio,a_trimestre,s_cod_coasegur,_borderaux,s_renglon,"ctatec",s_des_cod_clase,s_debito,s_credito,s_cod_clase);				
		end foreach

		-- Se coloca el saldo final x reasegurador

		foreach
			select cod_coasegur,
				   sum(participar)
			  into s_cod_coasegur, 
				   s_credito
			  from reacoest
			 where anio      = a_anio
			   and trimestre = a_trimestre
			   and borderaux = _borderaux 
			 group by cod_coasegur
			 order by cod_coasegur

			update reaestct1 
			   set saldo_final  = saldo_final + s_credito
			 where ano          = a_anio 
			   and trimestre    = a_trimestre 
			   and contrato     = _contrato
			   and reasegurador = s_cod_coasegur;
		end foreach
	end foreach
end if

---Segunda Parte
---Trimestre comienzan en enero

if a_actene = 1 then	--TRIMESTRE COMIENZA EN ENERO

	let _existe = 0;
	
	select periodo1,
		   periodo3
	  into _per_1,
		   _per_3
	  from reatrim
	 where ano       = a_anio2
	   and trimestre = a_trimestre2;

	foreach 
		select cod_contrato,nombre 
		  into _contrato,_desc_contrato 
		  from reacontr 
		 where activo = 1
		   and tipo   = 2

		let _existe = 0;

		select count(*) 
		  into _existe 
		  from reaestct1 
		 where ano       = a_anio2 
		   and trimestre = a_trimestre2 
		   and contrato  = _contrato;   -- debe existir encabezado 

		if _existe = 0 then
			foreach
				select distinct cod_coasegur
				  into s_cod_coasegur
				  from reacoest
				 where anio      = a_anio2
				   and trimestre = a_trimestre2
				   and borderaux = _contrato

				-- primer saldo en cero
				insert into reaestct1(
				ano,   
				trimestre,   
				reasegurador,   
				contrato,   
				saldo_inicial,   
				saldo_final,
				saldo_trim)
				values(
				a_anio2,   
				a_trimestre2,   
				s_cod_coasegur,   
				_contrato,   
				0,   
				0,
				0);
			end foreach
			delete from reaestct2 where ano = a_anio2 and trimestre = a_trimestre2 and contrato = _contrato;  -- elimina detalle
		end if
	end foreach

	foreach 
		select cod_contrato,nombre
		  into _contrato,_desc_contrato
		  from reacontr
		 where activo = 1
		   and tipo   = 2
		 order by 1

		let s_renglon  = 0;
		let s_debito   = 0;
		let s_credito  = 0;
		let _borderaux = _contrato;

		-- Participacion de Reaseguro
		-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%, 3-Terremoto(001,003)30%, 4-Ramos Tecnicos(010,011,012,014),
		-- 5-Fianzas(008,080), 6-Acc. Personales(004), 7-Vida Ind/Col(016,019)]					 
		foreach
			select reacoest.cod_coasegur,
				   reacoest.cod_clase,
				   reacoest.cod_contrato,
				   sum(reacoest.participar)
			  into s_cod_coasegur, 
				   s_cod_clase, 
				   s_cod_contrato, 
				   s_credito
			  from reacoest
			 where anio      = a_anio2
			   and trimestre = a_trimestre2
			   and borderaux = _borderaux 
			 group by reacoest.cod_coasegur,
					  reacoest.cod_clase,
					  reacoest.cod_contrato
			 order by reacoest.cod_coasegur,
					  reacoest.cod_clase,
					  reacoest.cod_contrato

			let s_debito = 0;

			if s_debito is null then
				let s_debito = 0 ;
			end if
			if s_credito is null then
				let s_credito =	0 ;
			end if

			select max(renglon)
			  into s_renglon
			  from reaestct2
			 where ano          = a_anio2
			   and trimestre    = a_trimestre2
			   and contrato     = _borderaux 
			   and reasegurador = s_cod_coasegur;

			if s_renglon is null then
				let s_renglon =	0 ;
			end if

			let s_renglon =	s_renglon + 1;

			if s_cod_contrato is null then
				let s_cod_contrato =	"";
			end if

			if s_cod_clase = 'INI' or s_cod_clase = 'MUI' then
				let s_cod_clase = "002";
			end if

			if s_cod_clase = 'INT' or s_cod_clase = 'MUT' then
				let s_cod_clase = "003";
			end if

			select nombre
			  into s_des_cod_clase
			  from rearamo
			 where ramo_reas = s_cod_clase;
	
			if s_cod_clase = '001' or s_cod_clase = '006' or s_cod_clase = '007' or s_cod_clase = '012' then 
			   let s_des_cod_clase = trim(s_des_cod_clase)||" - Cuota Parte Serie "||trim(s_cod_contrato);
			else 
			   let s_des_cod_clase = trim(s_des_cod_clase)||" - Excedente Serie "||trim(s_cod_contrato);
			end if 

			if s_credito < 0 then 
			   let s_debito  = -1 * s_credito;
			   let s_credito =	0;
			end if 

			insert into reaestct2 (ano,trimestre,reasegurador,contrato,renglon,concepto1,concepto2,debe,haber,ramo_reas)
			values (a_anio2,a_trimestre2,s_cod_coasegur,_borderaux,s_renglon,"ctatec",s_des_cod_clase,s_debito,s_credito,s_cod_clase);				
		end foreach

		-- Se coloca el saldo final x reasegurador
		foreach
			select reacoest.cod_coasegur,
				   sum(reacoest.participar)
			  into s_cod_coasegur, 
				   s_credito
			  from reacoest
			 where anio      = a_anio2
			   and trimestre = a_trimestre2
			   and borderaux = _borderaux 
			 group by cod_coasegur
			 order by cod_coasegur

			update reaestct1 
			   set saldo_final  = saldo_final + s_credito
			 where ano          = a_anio2 
			   and trimestre    = a_trimestre2 
			   and contrato     = _contrato
			   and reasegurador = s_cod_coasegur;
		end foreach
	end foreach
end if
end

-- Cambiar el estado del borderaux del trimestre procesado
if a_actjul = 1 then
	update reatrim
	   set status_borderaux = "C" 
	 where ano              = a_anio
	   and trimestre        = a_trimestre
	   and tipo             = 1;
end if

if a_actene = 1 then
	update reatrim
	   set status_borderaux = "C" 
	 where ano              = a_anio2
	   and trimestre        = a_trimestre2
	   and tipo             = 2;
end if

return 0,"PROCESO REALIZADO CON EXITO";

end procedure;		