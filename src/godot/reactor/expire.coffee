###
expire.js: Stream for filtering expired TTLs.
(C) 2012, Charlie Robbins, Jarrett Cruger, and the Contributors.
###


stream   = require "readable-stream"


#
# ### function Expire (ttl)
# #### @ttl {Number} Length of TTL to wait before expiring.
# Constructor function of the Expire stream responsible for filtering
# expired TTLs. **Defaults to 5-minute TTLs.**
#
class Expire extends stream.Transform
  constructor: (@ttl) ->
    super objectMode: true

    @ttl     or= 60 * 5
    @expired   = false
    @resetTtl()
    @on "end", @clearTimeout

  #
  # ### function write (data)
  # #### @data {Object} JSON to check against TTL.
  # Stores the last `data` received by this instance
  # and resets the TTL timeout.
  #
  _transform: (data, encoding, done) ->
    #
    # Stop emitting data events after this instance
    # expires.
    #
    # Remarks:
    #   * Is this the behavior we want?
    #   * Should we override this.ttl with
    #     data.ttl?
    #
    unless @expired
      @last = data
      @resetTtl()

    done()

  #
  # ### function resetTtl ()
  # Resets the TTL timeout for this instance.
  #
  resetTtl: ->
    @clearTimeout()
    @ttlId = setTimeout @afterWait, @ttl * 1000

  afterWait: =>
    @clearTimeout()
    @expired = true
    @push @last if @last?

  clearTimeout: =>
    clearTimeout @ttlId if @ttlId


module.exports = Expire
