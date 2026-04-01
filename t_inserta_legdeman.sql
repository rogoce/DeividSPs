--DROP trigger t_inserta_legdeman;
CREATE TRIGGER t_inserta_legdeman UPDATE OF estatus_actual,expediente,instancia,pronostico,juzgado,cod_abogado,numrecla,
tipo_demanda,monto_cuantia,demandante,demandado on legdeman
REFERENCING OLD AS o NEW AS n
	FOR EACH ROW(EXECUTE PROCEDURE sp_leg02() WITH TRIGGER REFERENCES);