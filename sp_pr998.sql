drop procedure sp_pr998;
create procedure "informix".sp_pr998(a_borderaux CHAR(2),a_reaseguro CHAR(3))
returning char(9),smallint,CHAR(3),VARCHAR(10),decimal(16,2),decimal(16,2)

-- Despliega los Saldos de Estado de Cuenta de Reaseguro
-- Creado por Henry Giron
-- Fecha 13/11/2009

DEFINE _anio_reas,_per_ano,a_anio 	    Char(9);
DEFINE _trim_reas,_trim, a_trimestre	Smallint;
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

LET _existe = 0;
LET _SALDO = 0;

begin
--  sp_rea002(:ls_periodo2)  retorna anio, trimestre, borderaux
--  borderoux BOUQUET

	SET ISOLATION TO DIRTY READ;
--	CALL sp_rea002(a_periodo2) RETURNING _anio_reas,_trim_reas; 

FOREACH 
	select cod_contrato,nombre
	into _contrato,_desc_contrato
	from reacontr
	where activo = 1
	and cod_contrato = a_borderaux

--		INSERT INTO reaestct2 (ano,trimestre,reasegurador,contrato,renglon,concepto1,concepto2,debe,haber,ramo_reas )

		FOREACH
			select anio,trimestre,ramo_reas,sum(debe),sum(haber)
			into a_anio,a_trimestre,s_cod_clase,s_debito,s_credito 
			FROM reaestct2 
			where contrato = _contrato
			and reasegurador = a_reaseguro
			and status_borderaux = "C" 
			and status_trimestre = "A"       -- Si no existe hay error. 

			select nombre
			into s_des_cod_clase
			from rearamo
			where ramo_reas = s_cod_clase ; 

			RETURN a_anio,
			a_trimestre,
			s_cod_clase,
			s_des_cod_clase, 
			s_debito,s_credito
            WITH RESUME;

		END FOREACH

END FOREACH

end 
end procedure  