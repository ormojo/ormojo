import Collector from './Collector'

export default class HydratingCollector extends Collector
	constructor: ({@hydrator}) ->
		super

	willCreateEntity: (store, entity) ->
		@hydrator.didRead(null, entity)

	willUpdateEntity: (store, previousEntity, entity) ->
		@hydrator.didUpdate(previousEntity, entity)

	willDeleteEntity: (store, entity) ->
		@hydrator.didDelete(entity)
