-- Genera Cheque ACH
-- Creado    : 08/06/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che123('2',0)

DROP PROCEDURE ap_rev_sac113am;
CREATE PROCEDURE ap_rev_sac113am()
RETURNING  smallint,				--Salud
		   char(20);

DEFINE  _error              integer;
DEFINE  _notrx              integer;
DEFINE  _error_desc         varchar(50);
define _cnt_origen,_cnt_origen1          integer;


SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

--begin work;

begin
on exception set _error
--    rollback work;
	return _error, "Error al Cambiar Tarifas...";
end exception


	{select distinct det.sac_notrx
	  into _notrx
	  from sac999:reacomp mae
	inner join sac999:reacompasie det on det.no_registro = mae.no_registro
	where mae.periodo = '2023-02' and mae.no_poliza in (
	select no_poliza from endedmae
	where actualizado = 1
	and no_poliza in (
	select no_poliza
	from emipomae
	where actualizado = 1
	and cod_ramo in('002','020','023')
	and no_poliza in (
	select distinct no_poliza
	from emifacon
	where cod_contrato = '00731')))}
	
let _cnt_origen = 0;
foreach
		/*select distinct det.sac_notrx
		  into _notrx
		  from sac999:reacomp mae
		  inner join sac999:reacompasie det on det.no_registro = mae.no_registro
		  inner join sac999:reacompasiau aux on aux.no_registro = det.no_registro and aux.cuenta = det.cuenta and aux.cod_auxiliar = 'BQ147'
		 where mae.periodo = '2024-07'*/

	{select res_notrx,
	       count(*)
	  into _notrx,
	       _cnt_origen
	  from (select distinct res_notrx,res_origen 
	          from cglresumen 
			 where res_fechatrx >= '01/01/2022' 
			   and res_notrx <> '1421724' 
			   and res_origen <> 'CGL')
	         group by 1
            having count(*) > 1
             order by res_notrx}
	--******		 
	{select distinct det.sac_notrx
	  into _notrx
	  from sac999:reacomp mae
	 inner join sac999:reacompasie det on det.no_registro = mae.no_registro
	 inner join sac999:reacompasiau aux on aux.no_registro = det.no_registro and aux.cuenta = det.cuenta and aux.cod_auxiliar = 'BQ063'
	 where mae.periodo = '2024-10'
	   and mae.no_documento[1,2] in('02','20','23')
	   and det.cuenta = '2550101'
	   and det.sac_notrx is not null}
	 --order by tipo_registro
	 
	SELECT distinct res_notrx
	into _notrx
    FROM cglresumen
   WHERE res_notrx in(	
1787742,1787743,1787744,1787745,1787746,1787747,1787748,1787749,1787750,1787751,1787752,1787753,
1787754,1787755,1787756,1787757,1787758,1787759,1787760,1787761,1787762,1787763,1787765,1787766,
1787767,1787768,1787769,1787770,1787771,1787772,1787773,1787774,1787775,1787776,1787777,1787778,
1787779,1787780,1787781,1787782,1787783,1787784,1787785,1787786,1787787,1787788,1787789,1787790,
1787791,1787792,1787793,1787794,1787795,1787796,1787797,1787798,1787799,1787800,1787801,1787802,
1787803,1787804,1787805,1787806,1787807,1787808,1787809,1787810,1787811,1787812,1787813,1787814,
1787815,1787816,1787817,1787818,1787819,1787820,1787821,1787822,1787823,1787824,1787825,1787826,
1787827,1787828,1787829,1787830,1787831,1787832,1787833,1787834,1787835,1787836,1787837,1787838,
1787839,1787840,1787841,1787842,1787843,1787844,1787845,1787846,1787847,1787848,1787849,1787850)	

	
	call sp_sac77(_notrx) returning _error, _error_desc;
	
	--let _cnt_origen = _cnt_origen + 1;
	
	{if _error = 0 then
		update tmp_sac113
		   set procesado = 1,
			   error = _error,
			   descripcion = _error_desc
		 where notrx = _notrx;
	else
		update tmp_sac113
		   set error = _error,
			   descripcion = _error_desc
		 where notrx = _notrx;
    end if}
	
end foreach
end
--commit work;
return 0, 'Actualizacion exitosa';
END PROCEDURE	  