-- Cierres de Borderaux
-- Creado por Henry Giron
-- execute procedure sp_pr996("2009-2010",2,"03/03/2010")
-- Fecha 13/11/2009

drop procedure sp_pr996;
create procedure sp_pr996(a_anio char(9),a_trimestre smallint,a_fecha date,a_anio2 char(9), a_trimestre2 smallint, a_actjul integer, a_actene integer)
returning integer,char(75);


DEFINE _anio_reas,_per_ano				Char(9);
DEFINE _trim_reas,_trim					Smallint;
DEFINE _borderaux						CHAR(2); 
DEFINE _existe							Smallint;
DEFINE _contrato						CHAR(2);
DEFINE _desc_contrato				 	CHAR(50);

DEFINE s_renglon            			SMALLINT;
DEFINE s_debito,s_credito   			DECIMAL(16,2);
DEFINE s_p_partic						DECIMAL(16,2);
DEFINE s_cod_clase						VARCHAR(10);
DEFINE c_cod_ramo						VARCHAR(10);
DEFINE s_cod_contrato					VARCHAR(10);
DEFINE s_des_cod_clase      			VARCHAR(10);
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
DEFINE _prox_per1,_prox_per3,_prox_per4	CHAR(7);
DEFINE _prox_ano						CHAR(4);
DEFINE _prox_mes						CHAR(2);
DEFINE _SALDO							decimal(16,2);
define _error							integer;
define _error_desc						char(50);

SET ISOLATION TO DIRTY READ;
LET _error  = 0;
LET _existe = 0;
LET _SALDO  = 0;

--set debug file to "sp_pr996.trc";
--trace on;

--begin work;

begin
on exception set _error
--rollback work;
return _error, "Error al Actualizar los borderaux.";
end exception

--Busca trimestre siguiente
if a_actjul = 1 then

	select periodo1,periodo3
	  into _prox_per1,_prox_per3
	  from reatrim
	 where ano              = a_anio  
	   and trimestre        = a_trimestre 
	   and status_borderaux = "C" 
	   and status_trimestre = "A"
	   and tipo             = 1;

	-- verifico primero remesas actualizadas
	select count(*)
	  into _existe
	  from reatrx1 r, reacontr t
	 where r.cod_contrato = t.cod_contrato
	   and r.actualizado = 0
	   and r.periodo BETWEEN _prox_per1 AND _prox_per3
	   and t.tipo = 1;

	if _existe > 0 then 
	   return 1,"Remesas sin Actualizar correspondientes al "||a_anio||"-"||a_trimestre;
	end if

	LET _prox_ano = _prox_per3[1,4];
	LET _prox_mes = _prox_per3[6,7];

	if 	_prox_mes = "12" then
		LET _prox_mes = "01" ;
		LET _prox_ano = _prox_ano + 1;
	else
		LET _prox_mes = _prox_mes + 1;
		if _prox_mes < 10 then
			let _prox_mes = '0' || _prox_mes;
		end if
	end if

	LET _prox_per4 = _prox_ano||"-"||_prox_mes;	--proximo trimestre

	--Busca anno trimestre del proximo trimestre
	select ano,
	       trimestre
	  into _per_ano,
	       _trim
	  from reatrim
	 where periodo1 = _prox_per4 
	   and status_borderaux = "A" and status_trimestre = "A"
	   and tipo = 1;

	FOREACH
	 
		select cod_contrato,nombre
		  into _contrato,_desc_contrato
	      from reacontr
		 where activo = 1
		   and tipo   = 1

		select count(*) 
		  into _existe 
		  from reaestct1 
		 where ano       = a_anio  
		   and trimestre = a_trimestre 
		   and contrato  = _contrato;

			if _existe = 0 then 
				CONTINUE FOREACH;
				--return 1,"NO ENCONTRO DATOS DEL CIERRE "||a_anio||"-"||a_trimestre;
			end if

			--delete FROM reaestct1 where ano = _per_ano and trimestre = _trim and contrato = _contrato;  -- Elimina Detalle

			FOREACH 
				select reasegurador,saldo_inicial,saldo_final
				  into s_cod_coasegur, s_debito, s_credito 
				  from reaestct1 
				 where ano       = a_anio  
				   and trimestre = a_trimestre 	
				   and contrato  = _contrato

					LET _SALDO = s_debito + s_credito;

				 update reaestct1
				    set saldo_trim   = s_credito,
					    saldo_final	 = _SALDO
				  where ano          = a_anio  
				    and trimestre    = a_trimestre 	
				    and contrato     = _contrato
				    and reasegurador = s_cod_coasegur;

				select count(*) 
				  into _existe 
				  from reaestct1 
				 where ano          = _per_ano  
				   and trimestre    = _trim
				   and contrato     = _contrato
  				   and reasegurador = s_cod_coasegur;

				 if _existe = 0 then

				  	INSERT INTO reaestct1  
				         ( ano,   
				           trimestre,   
				           reasegurador,   
				           contrato,   
				           saldo_inicial,   
				           saldo_final,
				           saldo_trim)  
				  	VALUES (_per_ano,   
				           _trim,   
				           s_cod_coasegur,   
				           _contrato,   
				           _SALDO,   
				           0,
				           0);
				 else
					 update reaestct1
					    set saldo_trim    = 0,
							saldo_final   = 0,
							saldo_inicial = _SALDO
					  where ano          = _per_ano  
					    and trimestre    = _trim
					    and contrato     = _contrato
					    and reasegurador = s_cod_coasegur;

				 end if
					--DELETE FROM reaestct2 where ano = _per_ano and trimestre = _trim and contrato = _contrato;  -- Elimina Detalle

			END FOREACH

	END FOREACH
end if

--Trim comienza en enero, Busca trimestre siguiente

if a_actene = 1 then

	select periodo1,periodo3
	  into _prox_per1,_prox_per3
	  from reatrim
	 where ano              = a_anio2  
	   and trimestre        = a_trimestre2 
	   and status_borderaux = "C" 
	   and status_trimestre = "A"
	   and tipo             = 2;

	-- verifico primero remesas actualizadas
	select count(*)
	  into _existe
	  from reatrx1 r, reacontr t
	 where r.cod_contrato = t.cod_contrato
	   and r.actualizado = 0
	   and r.periodo BETWEEN _prox_per1 AND _prox_per3
   	   and t.tipo = 2;

	if _existe > 0 then 
	   return 1,"Remesas sin Actualizar correspondientes al "||a_anio2||"-"||a_trimestre2;
	end if

	LET _prox_ano = _prox_per3[1,4];
	LET _prox_mes = _prox_per3[6,7];

	if 	_prox_mes = "12" then
		LET _prox_mes = "01" ;
		LET _prox_ano = _prox_ano + 1;
	else
		LET _prox_mes = _prox_mes + 1;
		if _prox_mes < 10 then
			let _prox_mes = '0' || _prox_mes;
		end if
	end if

	LET _prox_per4 = _prox_ano||"-"||_prox_mes;	--proximo trimestre

	--Busca anno trimestre del proximo trimestre
	select ano,
	       trimestre
	  into _per_ano,
	       _trim
	  from reatrim
	 where periodo1 = _prox_per4 
	   and status_borderaux = "A" and status_trimestre = "A"
	   and tipo = 2;

	FOREACH
	 
		select cod_contrato,nombre
		  into _contrato,_desc_contrato
	      from reacontr
		 where activo = 1
		   and tipo   = 2

		select count(*) 
		  into _existe 
		  from reaestct1 
		 where ano       = a_anio2  
		   and trimestre = a_trimestre2
		   and contrato  = _contrato;

			if _existe = 0 then 
				CONTINUE FOREACH;
				--return 1,"NO ENCONTRO DATOS DEL CIERRE "||a_anio||"-"||a_trimestre;
			end if

			--delete FROM reaestct1 where ano = _per_ano and trimestre = _trim and contrato = _contrato;  -- Elimina Detalle


			FOREACH 
				select reasegurador,saldo_inicial,saldo_final
				  into s_cod_coasegur, s_debito, s_credito 
				  from reaestct1 
				 where ano       = a_anio2  
				   and trimestre = a_trimestre2 	
				   and contrato  = _contrato

					--let s_debito = s_debito * -1;
					LET _SALDO   = s_debito + s_credito;

				 update reaestct1
				    set saldo_trim   = s_credito,
					    saldo_final	 = _SALDO
				  where ano          = a_anio2  
				    and trimestre    = a_trimestre2 	
				    and contrato     = _contrato
				    and reasegurador = s_cod_coasegur;

				select count(*) 
				  into _existe 
				  from reaestct1 
				 where ano          = _per_ano  
				   and trimestre    = _trim
				   and contrato     = _contrato
  				   and reasegurador = s_cod_coasegur;


				 if _existe = 0 then

				  	INSERT INTO reaestct1  
				         ( ano,   
				           trimestre,   
				           reasegurador,   
				           contrato,   
				           saldo_inicial,   
				           saldo_final,
				           saldo_trim)  
				  	VALUES (_per_ano,   
				           _trim,   
				           s_cod_coasegur,   
				           _contrato,   
				           _SALDO,   
				           0,
				           0);
				 else

					 update reaestct1
					    set saldo_trim    = 0,
							saldo_final   = 0,
							saldo_inicial = _SALDO
					  where ano          = _per_ano  
					    and trimestre    = _trim
					    and contrato     = _contrato
					    and reasegurador = s_cod_coasegur;

				 end if

					--DELETE FROM reaestct2 where ano = _per_ano and trimestre = _trim and contrato = _contrato;  -- Elimina Detalle

			END FOREACH

	END FOREACH
end if

-- Cambiar el estado del borderaux del trimestre procesado
if a_actjul = 1 then
	update reatrim
	   set status_trimestre = "C" 
	 where ano              = a_anio	
	   and trimestre        = a_trimestre
	   and status_borderaux = "C"
	   and tipo             = 1;

end if
if a_actene = 1 then
	update reatrim
	   set status_trimestre = "C" 
	 where ano              = a_anio2
	   and trimestre        = a_trimestre2
	   and status_borderaux = "C"
	   and tipo             = 2;
end if

IF _error = 1 THEN
	--rollback work;
	RETURN  _error, "ERROR DE CIERRE del Anio "||a_anio||" TRIMESTRE "||a_trimestre;
END IF	

--commit work;	
RETURN  _error,"PROCESO REALIZADO CON EXITO";
end 
end procedure
   