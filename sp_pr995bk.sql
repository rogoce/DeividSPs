-- Pase de Borderaux a Estado de Cuenta
-- execute procedure sp_pr995("2009-2010",2,"03/03/2010")
-- Creado por Henry Giron
-- Fecha 13/11/2009
--sp_pr127("001","001",_per_1,_per_3,"*","*","*","*","001,003,006,008,010,011,012,013,014,021,022;","*","*","2012,2011,2010,2009,2008;")

--drop procedure sp_pr995;
create procedure "informix".sp_pr995(a_anio char(9),a_trimestre smallint,a_fecha date)
returning integer,char(50);

DEFINE _anio_reas						Char(9);
DEFINE _trim_reas						Smallint;
DEFINE _borderaux						CHAR(2); 
DEFINE _existe							Smallint;
DEFINE _contrato						CHAR(2);
DEFINE _desc_contrato				 	CHAR(50);

DEFINE s_renglon            			SMALLINT;
DEFINE s_debito,s_credito   			DECIMAL(16,2);
DEFINE s_p_partic						DECIMAL(16,2);
DEFINE s_cod_clase						VARCHAR(3);
DEFINE c_cod_ramo						VARCHAR(10);
DEFINE s_cod_contrato					VARCHAR(5);
DEFINE s_des_cod_clase      			VARCHAR(255);

DEFINE s_existe  						SMALLINT;
DEFINE _eexiste							SMALLINT;
DEFINE _eno_remesa					    CHAR(10);

DEFINE _ecod_compania					CHAR(3);
DEFINE _ecod_sucursal					CHAR(3);
DEFINE _etipo							CHAR(2);
DEFINE _efecha							date;
DEFINE _ecod_coasegur					CHAR(3);
DEFINE _ecod_contrato					CHAR(2);
DEFINE _eperiodo						CHAR(7);
DEFINE _ecomprobante					CHAR(8);
DEFINE _econcepto						CHAR(3);
DEFINE _emoneda							CHAR(2);
DEFINE _eccosto							CHAR(3);
DEFINE _edescrip						CHAR(100);
DEFINE _emonto							decimal (16,2);
DEFINE _edebito							decimal (16,2);
DEFINE _ecredito						decimal (16,2);
DEFINE _eusuario						CHAR(15);
DEFINE _eactualizado					SMALLINT;
DEFINE _esac_asientos					SMALLINT;
DEFINE _ecod_banco						CHAR(3);
DEFINE _dno_remesa						SMALLINT;
DEFINE _dcod_compania					CHAR(3);
DEFINE _dcod_sucursal					CHAR(3);
DEFINE _dtipo							CHAR(2);
DEFINE _drenglon						smallint;
DEFINE _dcod_coasegur					CHAR(3);
DEFINE _dcod_ramo						CHAR(3);
DEFINE _dcod_contrato					CHAR(2);
DEFINE _dno_recibo						CHAR(10);
DEFINE _dfecha							DATE;
DEFINE _dcuenta							CHAR(12);
DEFINE _dccosto							CHAR(3);
DEFINE _ddebito							decimal(16,2);
DEFINE _dcredito						decimal(16,2);
DEFINE _dactualizado					smallint;
DEFINE s_cod_coasegur 					CHAR(3);
DEFINE _per_1,_per_3					CHAR(7);
define _error							integer;
define _error_desc						char(50);

begin
SET ISOLATION TO DIRTY READ;  

LET _existe = 0;
	
select periodo1,
       periodo3
  into _per_1,
       _per_3
  from reatrim
 where ano       = a_anio
   and trimestre = a_trimestre;

{CALL sp_pr127("001","001",_per_1,_per_3,"*","*","*","*","*","*","*","*") RETURNING  _error, _error_desc;

IF _error = 1 THEN
	RETURN  _error,"No Genero Saldos de Borderaux.";
END IF}

FOREACH 
	select cod_contrato,nombre 
	  into _contrato,_desc_contrato 
	  from reacontr 
	 where activo = 1 

	let _existe = 0;

	select count(*) 
	  into _existe 
	  from reaestct1 
	 where ano       = a_anio 
	   and trimestre = a_trimestre 
	   and contrato  = _contrato;   -- Debe existir encabezado 

	if _existe = 0 then 

		FOREACH
			 select distinct cod_coasegur
			   into s_cod_coasegur
			   from reacoest
			  where anio      = a_anio
				and trimestre = a_trimestre
				and borderaux = _contrato

				-- primer saldo en cero
				INSERT INTO reaestct1(
				ano,   
				trimestre,   
				reasegurador,   
				contrato,   
				saldo_inicial,   
				saldo_final,
				saldo_trim)
				VALUES(
				a_anio,   
				a_trimestre,   
				s_cod_coasegur,   
				_contrato,   
				0,   
				0,
				0);
		END FOREACH
		--RETURN 1,"FALLO EN EL PROCESO, No existe CIERRE realizado. Anio: "||a_anio||" Trimestre: "||a_trimestre||" de "||_desc_contrato; -- Cierre de Trimestres
		delete from reaestct2 where ano = a_anio and trimestre = a_trimestre and contrato = _contrato;  -- Elimina Detalle
	end if

END FOREACH

FOREACH 
	select cod_contrato,nombre
	  into _contrato,_desc_contrato
	  from reacontr
	 where activo = 1
  order	by 1

	LET s_renglon  = 0;
	LET s_debito   = 0;
	LET s_credito  = 0;
	LET _borderaux = _contrato;

		-- Participacion de Reaseguro
		-- Clasificasion - 1-R.C.G.(006), 2-Incendio (001,003)70%, 3-Terremoto(001,003)30%, 4-Ramos Tecnicos(010,011,012,014),
    	--               - 5-Fianzas(008,080), 6-Acc. Personales(004), 7-Vida Ind/Col(016,019)]					 
		FOREACH
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
			    LET s_cod_contrato =	"";
			end if

			if s_cod_clase = 'INI' or s_cod_clase = 'MUI' then
			    LET s_cod_clase = "002";
			end if

			if s_cod_clase = 'INT' or s_cod_clase = 'MUT' then
			    LET s_cod_clase = "003";
			end if

			select nombre
			  into s_des_cod_clase
			  from rearamo
			 where ramo_reas = s_cod_clase;
	
			if s_cod_clase = '001' or s_cod_clase = '006' or s_cod_clase = '007' then 
			   LET s_des_cod_clase = trim(s_des_cod_clase)||" - Cuota Parte Serie "||trim(s_cod_contrato);
			else 
			   LET s_des_cod_clase = trim(s_des_cod_clase)||" - Excedente Serie "||trim(s_cod_contrato);
			end if 

			if s_credito < 0 then 
			   LET s_debito  = -1 * s_credito;
			   LET s_credito =	0;
			end if 

			INSERT INTO reaestct2 (ano,trimestre,reasegurador,contrato,renglon,concepto1,concepto2,debe,haber,ramo_reas)
			VALUES (a_anio,a_trimestre,s_cod_coasegur,_borderaux,s_renglon,"",s_des_cod_clase,s_debito,s_credito,s_cod_clase);
				
		END FOREACH

		-- Se coloca el saldo final x reasegurador

		FOREACH

			  select reacoest.cod_coasegur,
			         sum(reacoest.participar)
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

		END FOREACH


END FOREACH
END  

-- Cambiar el estado del borderaux del trimestre procesado

update reatrim
   set status_borderaux = "C" 
 where ano              = a_anio
   and trimestre        = a_trimestre;

return 0,"PROCESO REALIZADO CON EXITO";

end procedure;		